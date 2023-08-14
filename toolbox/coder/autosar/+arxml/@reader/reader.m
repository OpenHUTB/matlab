classdef(Hidden)reader<arxml.document











    methods
        function this=reader(filename)






            if nargin==1
                this.read(filename);
            end

        end

    end

    methods(Hidden)
        read(this,aFilename)
    end

end
