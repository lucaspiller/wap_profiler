class Main
  get '/uaprof/*' do
    uri = params[:splat][0]

    begin
      # lets see what we have
      ua_prof = UaProf.find_or_create(uri)

      # change status depending on whether pending or not
      if ua_prof.pending?
        status 202
      else
        status 200
      end

      # return json
      ua_prof.to_json
    rescue URI::InvalidURIError => e
      # the uri is invalid
      status 400
      e.message
    end
  end
end
