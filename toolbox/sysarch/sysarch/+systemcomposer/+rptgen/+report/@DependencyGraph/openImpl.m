function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2CxoUSQAQVLCeFmWn6Mb+zkcgVf1zW6YRwmWqtBCbO4o5WIGvi18CstqS2/'...
        ,'HoPHkI6P9HU+I0awq9QmoxD3jiWskPpKLIVIhjIUksYkwXNILv9QwL5HQks3'...
        ,'WairkTZiV+TWA5GthDuJ/d00ISgizOYhwgMqRCsSJ+eCsfyWF3/u3V2vORdz'...
        ,'5Q8hGnqnt5/cp2Vv03rEt3uXzQ9961YyARl+wiITFXTSnIOpJ/QUsuf59KDB'...
        ,'jruNN+hivJ3B1kwZNpRd0XdzQksaabnDd3bsSmGqZWQNLQKkcLowJCTaRe3R'...
        ,'zlmUj7IET/Vz05oQTgWpmzx4'];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end