require 'sqlite3'
require 'rubygems'

class Student
    @db = SQLite3::Database.open('db/studentbody.db')

    @db.results_as_hash = true

    @@attributes = @db.execute("PRAGMA table_info(students)").map do |column|
      column[1].to_sym
    end

    @@attributes.each do |attribute|
      attr_accessor attribute
    end

    def self.find(id)
      student = Student.new
      @db.results_as_hash = true
      result = @db.execute("SELECT * FROM students WHERE id = #{id}")[0]
      @@attributes.each do |attribute|
        student.send("#{attribute}=", result[attribute.to_s])
      end
      student
    end

    def self.find_by_slug(slug)
      student = Student.new
      @db.results_as_hash = true
      result = @db.execute("SELECT * FROM students WHERE slug = '#{slug.downcase}'")[0]
      @@attributes.each do |attribute|
        student.send("#{attribute}=", result[attribute.to_s])
      end
      student
    end

    def self.all
      students = []
      student_info = @db.execute("SELECT * FROM students")
      student_info.each do |info|
        id = info[0]
        students << Student.find(id)
      end
      students
    end

  end