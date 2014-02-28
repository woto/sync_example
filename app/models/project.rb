class Project < ActiveRecord::Base
  belongs_to :user
  has_many :todos, dependent: :destroy
  has_many :comments, through: :todos

  def completed_todo_count
    self.todos.completed.count
  end

  def self.empty
    includes(:todos).references(:todos).group('projects.id').having('count(todos.id) = 0')
  end

  def self.incomplete
    includes(:todos).where(todos: { complete: false})
  end

  def self.complete
    includes(:todos).where(todos: { complete: true})
  end

end
