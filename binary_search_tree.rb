class Node
  include Comparable
  attr_accessor :data, :left, :right

  def <=>(other)
    data <=> other.data
  end

  def initialize(data)
    @data = data
    @left = nil
    @right = nil
  end

  def inspect
    @data
  end
end

class Tree
  attr_accessor :root

  def initialize(arr)
    @root = build_tree(arr.sort.uniq)
  end

  def build_tree(arr)
    return nil if arr.empty?

    mid = arr.length / 2
    root = Node.new(arr[mid])
    root.left = build_tree(arr[...mid])
    root.right = build_tree(arr[mid + 1..])
    root
  end

  def insert(value, root = @root)
    return Node.new(value) if root.nil?

    if root.data == value
      return root
    elsif root.data < value
      root.right = insert(value, root.right)
    elsif root.data > value
      root.left = insert(value, root.left)
    end

    root
  end

  def delete(value, root = @root)
    return root if root.nil?

    # First check for the node we are looking for, traversing accordingly.
    if root.data > value
      root.left = delete(value, root.left)
      return root
    elsif root.data < value
      root.right = delete(value, root.right)
      return root
    end

    # First check if the node has only one child.
    # If it does, just swap the values.
    if root.left.nil?
      root.right
    elsif root.right.nil?
      root.left
    # Next check if it has both children, in which case
    # we make it so that the lowest of the values in its right subtree gets swapped.
    # This works even if it has no children, where nil gets assigned directly.
    else
      succ_parent = root
      succ = root.right
      until succ.left.nil?
        succ_parent = succ
        succ = succ.left
      end
      if succ_parent == root
        succ_parent.right = succ.right
      else
        succ_parent.left = succ.right
      end
      root.data = succ.data
      root
    end
  end

  def find(value, root = @root)
    return nil if root.nil?

    if root.data == value
      root
    elsif root.data < value
      find(value, root.right)
    elsif root.data > value
      find(value, root.left)
    end
  end

  # When a block is given, yields each node
  # Otherwise, an array of values is returned
  def level_order(root = @root)
    return if root.nil?

    queue = [root]
    level_order_nodes = []
    until queue.empty?
      current = queue.last
      block_given? ? yield(current) : level_order_nodes.push(current.data)
      queue.unshift(current.left) unless current.left.nil?
      queue.unshift(current.right) unless current.right.nil?
      queue.pop
    end
    level_order_nodes unless block_given?
  end

  # When a block is given, yields each node
  # Otherwise, an array of values is returned
  def inorder(root = @root, arr = [])
    return if root.nil?

    inorder(root.left, arr)
    block_given? ? yield(root) : arr.push(root.data)
    inorder(root.right, arr)
    arr unless block_given?
  end

  # When a block is given, yields each node
  # Otherwise, an array of values is returned
  def preorder(root = @root, arr = [])
    return if root.nil?

    block_given? ? yield(root) : arr.push(root.data)
    inorder(root.left, arr)
    inorder(root.right, arr)
    arr unless block_given?
  end

  # When a block is given, yields each node
  # Otherwise, an array of values is returned
  def postorder(root = @root, arr = [])
    return if root.nil?

    inorder(root.left, arr)
    inorder(root.right, arr)
    block_given? ? yield(root) : arr.push(root.data)
    arr unless block_given?
  end

  def height(node, height = -1)
    return height if node.nil?

    height += 1
    height1 = height(node.left, height)
    height2 = height(node.right, height)
    height1 > height2 ? height1 : height2
  end

  def depth(node, depth = 0, root = @root)
    return nil if root.nil?

    if root == node
      depth
    elsif root < node
      depth(node, depth + 1, root.right)
    elsif root > node
      depth(node, depth + 1, root.left)
    end
  end

  def balanced?
    level_order do |node|
      l_height = node.left ? height(node.left) : 0
      r_height = node.right ? height(node.right) : 0
      return false if (l_height - r_height).abs > 1
    end
    true
  end

  def rebalance
    return if balanced?

    @root = build_tree(inorder)
  end
end
