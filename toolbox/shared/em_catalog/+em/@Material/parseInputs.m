function parseInputs(obj,varargin)













    materialtype=find(obj.CatalogObject,'Air');
    propList={'Name','EpsilonR','LossTangent','Thickness'};
    if~isempty(varargin)&&...
        all(cellfun(@isstr,varargin,'UniformOutput',true))&&...
        isempty(intersect(varargin,propList))




        usermaterial=cellfun(@(x)find(obj.CatalogObject,x),varargin,'UniformOutput',false);
        if any(cellfun(@isempty,usermaterial))

            error(message('antenna:antennaerrors:InvalidOption'));
        end

        usermaterial=cellfun(@(x)find(obj.CatalogObject,x),varargin,'UniformOutput',true);
        if~isempty(usermaterial)
            materialtype=usermaterial;
            obj.Name={materialtype(size(materialtype,1):size(materialtype,2)).Name};
            obj.EpsilonR=[materialtype(size(materialtype,1):size(materialtype,2)).Relative_Permittivity];
            obj.LossTangent=[materialtype(size(materialtype,1):size(materialtype,2)).Loss_Tangent];
            obj.DielectricStruct.Thickness=6e-3;
            obj.Frequency=[materialtype(size(materialtype,1):size(materialtype,2)).Frequency];
            obj.Shape='box';
        end
    else
        parserObj=inputParser;
        addParameter(parserObj,'Name',materialtype.Name);
        addParameter(parserObj,'EpsilonR',materialtype.Relative_Permittivity);
        addParameter(parserObj,'LossTangent',materialtype.Loss_Tangent);
        addParameter(parserObj,'Frequency',materialtype.Frequency);
        addParameter(parserObj,'Length',1e-2);
        addParameter(parserObj,'Width',1e-2);
        addParameter(parserObj,'Thickness',6e-3);
        addParameter(parserObj,'Shape','box');
        parse(parserObj,varargin{:});
        obj.Name=parserObj.Results.Name;
        obj.EpsilonR=parserObj.Results.EpsilonR;
        obj.LossTangent=parserObj.Results.LossTangent;
        obj.Frequency=parserObj.Results.Frequency;
        obj.DielectricStruct.Length=parserObj.Results.Length;
        obj.DielectricStruct.Width=parserObj.Results.Width;
        obj.DielectricStruct.Thickness=parserObj.Results.Thickness;
        obj.Shape=parserObj.Results.Shape;
    end

end
