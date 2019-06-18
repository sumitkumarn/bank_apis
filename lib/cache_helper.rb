module CacheHelper

  #This is a module for caching DB results. First time, the value is retrieved from DB and stored in a global variable.
  #Whenever, the methods are called, the respective global variables are checked. If they are not null, their values are returned.
  #If they are null, then DB query is fired and the result is cached.
  #Since this app supports only read operations for bank and branches table, no cache modification is done in the app life cycle.

  def city_from_cache
    $cities ||= begin
      Branch.select(:city).map(&:city).uniq #retrieves all distinct cities from branches table
    end
  end

  def bank_name_from_cache
    $banks ||= begin
      Bank.select(:name).map(&:name).uniq #retrieves all distinct bank names from banks table
    end
  end 

end