class BuildNotes
  include BuildParticipant

  def notes
    JSON.pretty_generate(generate_notes_hash)
  end

  def generate_notes_hash
    info "building new notes hash"
    native = build.send(:native)
    built_on = native.getBuiltOnStr || "master"
    built_on = "master" if built_on.empty?
    time = Time.at(native.getTimeInMillis / 1000.0)
    duration = Time.now - time

    {
      :built_on => built_on,
      :duration => duration,
      :full_display_name => native.getFullDisplayName,
      :id => native.getId,
      :number => native.getNumber,
      :result => native.getResult.toString,
      :status_message => native.getBuildStatusSummary.message,
      :time => time,
      :url => native.getUrl
    }
  end
  private :generate_notes_hash
end
