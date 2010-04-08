class Object
  # Returns a reference to the obkect's eigen (singleton) class.
  def eigen_class
    class << self
      self
    end
  end
end