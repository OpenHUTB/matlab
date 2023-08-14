


classdef SampleTimesConstraint<slci.compatibility.Constraint

    methods

        function obj=SampleTimesConstraint()
            obj=obj@slci.compatibility.Constraint();
            obj.setEnum('SampleTimes');
            obj.setCompileNeeded(1);
        end

        function out=getDescription(aObj)%#ok
            out='Asynchronous, variable, union, continuous and exported discrete sample times are not supported';
        end

        function out=check(aObj)
            out=[];
            times=Simulink.BlockDiagram.getSampleTimes(aObj.ParentModel().getHandle());
            asyncSampleTimes=false;
            variableSampleTimes=false;
            continuousSampleTimes=false;
            unionSampleTimes=false;
            finiteSampleTimes=0;
            unknownSampleTime=false;
            exportedDiscreteSampleTimes=false;
            explicitDiscretePartitionSampleTimes=false;
            dataDrivenSampleTimes=false;

            for i=1:numel(times)
                if strcmpi(times(i).Annotation(1),'M')

                elseif strcmpi(times(i).Annotation(1),'T')

                elseif~isempty(strfind(times(i).Annotation(1),'A'))
                    asyncSampleTimes=true;
                elseif~isempty(strfind(times(i).Annotation(1),'V'))
                    variableSampleTimes=true;
                elseif~isempty(strfind(times(i).Annotation,'Cont'))
                    continuousSampleTimes=true;
                elseif~isempty(strfind(times(i).Annotation(1),'F'))
                    exportedDiscreteSampleTimes=true;
                elseif strcmpi(times(i).Annotation(1),'P')
                    explicitDiscretePartitionSampleTimes=true;
                elseif~isempty(strfind(times(i).Annotation(1),'U'))
                    unionSampleTimes=true;
                elseif strcmpi(times(i).Annotation,'DD')
                    dataDrivenSampleTimes=true;
                elseif~isempty(strfind(times(i).Annotation(1),'D'))&&...
                    isfinite(times(i).Value(1))
                    finiteSampleTimes=finiteSampleTimes+1;
                elseif strcmpi(times(i).Annotation,'Inf')...
                    ||strcmpi(times(i).Annotation,'Const')



                elseif strcmpi(times(i).Annotation,'Prm')

                else

                    unknownSampleTime=true;
                end
            end
            if explicitDiscretePartitionSampleTimes
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'DiscretePartitionSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
            if dataDrivenSampleTimes
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'dataDrivenSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
            if continuousSampleTimes
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ContinuousSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
            if asyncSampleTimes
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'AsyncSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
            if unionSampleTimes
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'UnionSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
            if variableSampleTimes
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'VariableSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
            if exportedDiscreteSampleTimes
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ExportedDiscreteSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
            if unknownSampleTime
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'UnknownSampleTimes',...
                aObj.ParentModel().getName());
                return
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            if~varargin{1}
                violations=varargin{2};
                sampleTimeWarnStr='';
                len=numel(violations);
                for i=1:len
                    if(i==len)&&len>1
                        separator=[' ',DAStudio.message('Slci:compatibility:SLCIand'),' '];
                    else
                        separator=', ';
                    end
                    sampleTimeWarnStr=[sampleTimeWarnStr,separator...
                    ,DAStudio.message(['Slci:compatibility:',violations(i).getCode,'MA'])];%#ok<AGROW>
                    sampleTimeWarnStr=lower(sampleTimeWarnStr);
                end
                sampleTimeWarnStr(1)='';
                StatusText=DAStudio.message('Slci:compatibility:SampleTimesConstraintWarn',sampleTimeWarnStr);
            else
                StatusText=DAStudio.message('Slci:compatibility:SampleTimesConstraintPass');
            end
            RecAction=DAStudio.message('Slci:compatibility:SampleTimesConstraintRecAction');
            SubTitle=DAStudio.message('Slci:compatibility:SampleTimesConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:SampleTimesConstraintInfo');
        end
    end
end

