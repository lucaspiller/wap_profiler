class Main
  get '/uaprof/*' do
    uri = params[:splat][0]

    begin
      ua_prof = UaProf.find_or_create(uri)

      if ua_prof.pending?
        status 202
      else
        status 200
      end

      #ua_prof.to_json
      ua_prof.id

    rescue URI::InvalidURIError => e
      status 400
      e.message
    end
  end
end
