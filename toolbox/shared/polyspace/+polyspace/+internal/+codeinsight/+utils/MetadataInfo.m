classdef MetadataInfo



    properties(SetAccess=private)
        Name(1,1)string
        Type string
        Value string
        RealValue string
        MinValue string
        MaxValue string
        Description string
        Units string
    end

    properties(Hidden,SetAccess=private)
        IsA(1,1)string;
    end

    methods
        function self=MetadataInfo(...
            name,...
            fixdt,...
            value,...
            realValue,...
            minValue,...
            maxValue,...
            description,...
            units,...
            prmOrSig)

            self.Name=name;

            if isempty(fixdt)
                self.Type="";
            else
                self.Type=fixdt;
            end
            self.Value=value;





            if~isempty(realValue)
                self.RealValue=strjoin(string(realValue),' ');
            else

                self.RealValue='';
            end
            self.MinValue=minValue;
            self.MaxValue=maxValue;
            self.Description=description;
            self.Units=units;
            self.IsA=prmOrSig;
        end
    end
end

