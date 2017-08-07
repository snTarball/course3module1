#json.partial! "racers/racer", racer: @racer
json.extract! @racer, :id, :number, :first_name, :last_name, :gender, :group, :secs, :created_at, :updated_at
