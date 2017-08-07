require 'pp'

class Racer
	include ActiveModel::Model

	# Attributes that allow to set/get each of the following properties:
	# id, number, first_name, last_name, gender, group and secs
	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	def to_s
    	"#{@id}: #{@number}, #{@first_name} #{@last_name}, #{@gender}, #{@group}, #{@secs}"
  	end

	#######################
	# Database Connection #
	#######################

	#convinience method for access to client in console
	def self.mongo_client
		Mongoid::Clients.default
	end

	#convinience method for access to racer collection
	def self.collection
		self.mongo_client['racers']
	end

	######################
	# CRUD Model Methods #
	######################

  # Initializer that can set the properties of the class using the keys from a racers document.
	def initialize(params={})
	#switch between both internal and external views of id and population
	  @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
		@number=params[:number].to_i
		@first_name=params[:first_name]
		@last_name=params[:last_name]
		@gender=params[:gender]
		@group=params[:group]
		@secs=params[:secs].to_i
	end

	# Class method all.

	def self.all(prototype={}, sort={:number=>1}, skip=0, limit=nil)
		result=collection.find(prototype)
			.sort(sort)
			.skip(skip)
    	result=result.limit(limit) if !limit.nil?
	    return result
	end

	# Class method find.
	def self.find id
		result=collection.find(:_id => BSON::ObjectId.from_string(id)).first
		return result.nil? ? nil : Racer.new(result)
	end

	# Instance method save.
  def save
		result=self.class.collection
			.insert_one(number:@number, first_name:@first_name, last_name:@last_name, gender:@gender, group:@group, secs:@secs)
		@id=result.inserted_id.to_s
	end

	# Instance method update.
	def update(params)
		@number=params[:number].to_i
		@first_name=params[:first_name]
		@last_name=params[:last_name]
		@gender=params[:gender]
		@group=params[:group]
		@secs=params[:secs].to_i

		params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
		self.class.collection
			.find(:_id=>BSON::ObjectId.from_string(@id))
			.replace_one(params)
	end

	# Instance method destroy.
	def destroy
		self.class.collection
			.find(number:@number)
			.delete_one
	end

	######################################
	#  Completing Active Model Framework #
	######################################

  # Instance method persisted?.
  # Check to see if the primary key has been assigned.
	def persisted?
		!@id.nil?
	end

	# Two instance methods called created_at and updated_at that act as placeholders for property getters.
	# JSON marshalling will expect these two methods to be there by default.
	def created_at
		nil
	end
	def updated_at
		nil
	end

	######################
	#  Adding pagination #
	######################

	# Add a class method to the Racer class called paginate.
	def self.paginate(params)
		page=(params[:page] || 1).to_i
		limit=(params[:per_page] || 30).to_i
		skip=(page-1)*limit
		sort = {:number => 1}
		racers=[]
		all({}, sort, skip, limit).each do |doc|
      		racers << Racer.new(doc)
    	end
		total=collection.count
		WillPaginate::Collection.create(page, limit, total) do |pager|
			pager.replace(racers)
		end
	end
end
