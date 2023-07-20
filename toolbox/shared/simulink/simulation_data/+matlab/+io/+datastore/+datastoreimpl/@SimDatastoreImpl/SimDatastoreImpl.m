


classdef(Abstract)SimDatastoreImpl<matlab.io.datastore.TabularDatastore...
    &matlab.mixin.Copyable

    properties(Access=public)
        ReadSize=100;
    end

    properties(SetAccess=public)
        NumSamples;
        FileName;
    end

    properties(Access=protected,Hidden,Constant)
        NumberSamplesForPreview_=10;
    end

    methods(Abstract)
        nSamples=getNumSamples(this)
        data=preview(this,varargin)
        reset(this)
        tf=hasdata(this)
        p=progress(this)
    end

    methods(Abstract,Access=protected)
        [data,info]=readData(this)
        data=readAllData(this)
    end

    methods
        function disp(this)


            if this.getNumSamples()>0
                data=preview(this,6);
                [nRecords,~]=size(data);
                if nRecords>5
                    fprintf('    %s\n\n',...
                    message('SimulationData:Objects:DatastoreDispPreview').getString);
                    data=data(1:5,:);%#ok<NASGU>
                    dataStr=evalc('disp(data)');

                    if~matlab.internal.display.isHot
                        dataStr=regexprep(dataStr,'</?strong>','');
                    end

                    dataLines=strsplit(dataStr,newline,'CollapseDelimiters',false);
                    nonEmptyLines=~cellfun(@isempty,dataLines);
                    dataLines=dataLines(...
                    find(nonEmptyLines,1,'first'):find(nonEmptyLines,1,'last'));
                    Simulink.SimulationData.utDisplayTablePreviewLinesWithContinuation(dataLines);
                else
                    fprintf('    %s\n\n',...
                    message('SimulationData:Objects:DatastoreDispPreview').getString);
                    disp(data);
                end
            end
        end
    end
end
