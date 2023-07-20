classdef RCSHelper<handle




    properties
        CurrentAzimuthLength=2;
        CurrentElevationLength=2;
    end

    properties(Constant,Hidden)
        Instance=driving.internal.scenarioApp.RCSHelper;
    end

    properties(SetAccess=protected,Hidden)
        ImportDialog;
    end

    methods(Access=protected)
        function this=RCSHelper
        end
    end

    methods
        function dlgName=getImportDialogName(~)
            dlgName=getString(message('driving:scenarioApp:ImportRCSTitle'));
        end

        function labels=getImportDialogLabels(~)
            labels={...
            getString(message('driving:scenarioApp:RCSAzimuthAnglesLabel')),...
            getString(message('driving:scenarioApp:RCSElevationAnglesLabel')),...
            getString(message('driving:scenarioApp:RCSPatternLabel')),...
            };
        end

        function validVariables=validateImportVariables(this,index,variables,otherSelections)
            dataTypes={variables.class};
            validTypes={'double','single'};
            variables(~cellfun(@(c)any(strcmp(c,validTypes)),dataTypes))=[];
            if any(index==[1,2])
                variables=variables(arrayfun(@(a)numel(find(a.size~=1))<2,variables));
            else
                azVar=variables(strcmp({variables.name},otherSelections{1}));
                elVar=variables(strcmp({variables.name},otherSelections{2}));

                if isempty(azVar)
                    azLength=this.CurrentAzimuthLength;
                else
                    azLength=max(azVar.size);
                end

                if isempty(elVar)
                    elLength=this.CurrentAzimuthLength;
                else
                    elLength=max(elVar.size);
                end
                requiredSize=[max(elLength),max(azLength)];
                variables=variables(arrayfun(@(a)isequal(a.size,requiredSize),variables));
            end
            if isempty(variables)
                validVariables={};
            else
                validVariables={variables.name};
            end
        end
    end

    methods(Static)
        function[azimValue,patternValue]=parseAzimuth(azimString,patternValue)

            azimValue=parseVector(azimString);
            if isempty(azimValue)||any(azimValue>180)||any(azimValue<-180)
                error(message('driving:scenarioApp:BadRCSAzimuthAngles'));
            end

            patternValue=driving.internal.scenarioApp.RCSHelper.resizePattern(patternValue,numel(azimValue),[]);
        end

        function[elevValue,patternValue]=parseElevation(elevString,patternValue)

            elevValue=parseVector(elevString);
            if isempty(elevValue)||any(elevValue>90)||any(elevValue<-90)
                error(message('driving:scenarioApp:BadRCSElevationAngles'));
            end


            patternValue=driving.internal.scenarioApp.RCSHelper.resizePattern(patternValue,[],numel(elevValue));
        end

        function[pattern,wasResized]=resizePattern(pattern,azLength,elLength)

            wasResized=false;
            if~isempty(azLength)
                nCols=size(pattern,2);
                if azLength>nCols
                    pattern=[pattern,repmat(pattern(:,end),1,azLength-nCols)];
                    wasResized=true;
                elseif azLength<nCols
                    pattern=pattern(:,1:azLength);
                    wasResized=true;
                end
            end


            if~isempty(elLength)
                nRows=size(pattern,1);
                if elLength>nRows
                    pattern=[pattern;repmat(pattern(end,:),elLength-nRows,1)];
                    wasResized=true;
                elseif elLength<nRows
                    pattern=pattern(1:elLength,:);
                    wasResized=true;
                end
            end
        end

        function updateWidgets(azimWidget,elevWidget,patternWidget,spec,enab)


            set(azimWidget,'Enable',enab,...
            'String',mat2str(spec.RCSAzimuthAngles));
            set(elevWidget,'Enable',enab,...
            'String',mat2str(spec.RCSElevationAngles));
            set(patternWidget,'Enable',enab,...
            'RowName',spec.RCSElevationAngles,...
            'ColumnName',spec.RCSAzimuthAngles,...
            'Data',spec.RCSPattern);
        end

        function[az,el,pattern]=import(azLength,elLength,varargin)
            r=driving.internal.scenarioApp.RCSHelper.Instance;
            r.CurrentAzimuthLength=azLength;
            r.CurrentElevationLength=elLength;
            iDialog=r.ImportDialog;
            if isempty(iDialog)||~isvalid(iDialog)
                iDialog=matlabshared.application.ImportDialog(r);
                r.ImportDialog=iDialog;
            end
            [az,el,pattern]=open(iDialog,varargin{:});
        end
    end
end

function vector=parseVector(string)


    string=strrep(strrep(strrep(string,'[',''),']',''),',',' ');
    if contains(string,';')
        vector=[];
        return;
    end

    try
        vector=textscan(string,'%f');
        vector=vector{1}';
        if numel(vector)<numel(strfind(string,' '))+numel(strfind(string,','))
            vector=[];
        end
    catch ME %#ok<NASGU>
        vector=[];
    end

    if any(diff(vector)<=0)||any(isnan(vector))||any(isinf(vector))
        vector=[];
    end

end


