class Trex < LanguageBadge
  describe "T-Rex",
           skill:             'C',
           description:       "Have at least one original repo where C is the dominant language",
           for:               "having at least one original repo where C is the dominant language.",
           image_name:        'trex.png',
           providers:         :github,
           language_required: "C",
           number_required:   1

end