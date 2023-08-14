
classdef MATLABFunctionConfiguration<handle




















    properties(Hidden=true,SetAccess=private,GetAccess=private)
blockHandle
chartID
sfUddHandle
blockPath
    end

    properties(GetAccess=public,SetAccess=private,Dependent)



Path
    end

    properties(Dependent)


FunctionScript





        UpdateMethod Simulink.MATLABFunction.UpdateMethodEnum

SampleTime



Description



DocumentLink

SupportVariableSizing

AllowDirectFeedthrough

VectorOutputs1D

SaturateOnIntegerOverflow

        TreatAsFi Simulink.MATLABFunction.TreatAsFiEnum

        FimathMode Simulink.MATLABFunction.FimathModeEnum

Fimath
    end
    methods(Hidden=true,Access=private)
        function error=linkedOrLockedError(this)
            error=[];
            if(strcmp(get_param(this.blockHandle,'LinkStatus'),'resolved'))
                error=MException(...
                message('Simulink:blocks:LinkedMATLABFunction'));

            elseif(this.sfUddHandle.Iced==1||this.sfUddHandle.Locked==1)
                error=MException(...
                message('Simulink:blocks:LockedMATLABFunction'));
            end

        end
    end

    methods(Static,Hidden=true)
        function error=validateStringProperties(propertyName,inputString)
            error=[];
            if(~ischar(inputString)&&~isstring(inputString)...
                ||isempty(inputString)&&~(propertyName=="Description"||propertyName=="DocumentLink"))


                error=MException(...
                message('Stateflow:MATLABFunctionConfiguration:InvalidStringInput',...
                propertyName));

            end
        end

        function error=validateLogicalProperties(propertyName,...
            inputValue)
            error=[];
            if(isequal(inputValue,1)||isequal(inputValue,0))
                return;


            end
            if(~islogical(inputValue)||isempty(inputValue)||...
                ~isscalar(inputValue)||~isfinite(inputValue))
                error=MException(...
                message('Stateflow:MATLABFunctionConfiguration:InvalidLogicalInput',...
                propertyName));

            end

        end
    end

    methods

        function this=MATLABFunctionConfiguration(bHandle)
            this.blockHandle=bHandle;
            this.chartID=sfprivate('block2chart',this.blockHandle);
            this.sfUddHandle=idToHandle(sfroot,this.chartID);
            this.blockPath=getfullname(this.blockHandle);
        end


        function path=get.Path(this)
            path=getfullname(this.blockHandle);
        end


        function set.FunctionScript(this,script)
            propertyName='FunctionScript';
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            errorString=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateStringProperties(...
            propertyName,script);
            if(~isempty(errorString))
                throwAsCaller(errorString);
            end
            this.sfUddHandle.Script=script;
        end

        function FunctionScript=get.FunctionScript(this)
            FunctionScript=this.sfUddHandle.Script;
        end


        function Description=get.Description(this)
            Description=this.sfUddHandle.Description;
        end

        function set.Description(this,blockDescription)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            propertyName='Description';
            errorString=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateStringProperties(...
            propertyName,blockDescription);
            if(~isempty(errorString))
                throwAsCaller(errorString);
            end

            this.sfUddHandle.Description=blockDescription;
        end


        function DocumentLink=get.DocumentLink(this)
            DocumentLink=this.sfUddHandle.Document;
        end

        function set.DocumentLink(this,documentLink)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            propertyName='DocumentLink';
            errorString=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateStringProperties(...
            propertyName,documentLink);
            if(~isempty(errorString))
                throwAsCaller(errorString);
            end
            this.sfUddHandle.Document=documentLink;
        end


        function UpdateMethod=get.UpdateMethod(this)
            if((strcmp(this.sfUddHandle.ChartUpdate,'CONTINUOUS')))
                UpdateMethod=Simulink.MATLABFunction.UpdateMethodEnum.Continuous;
            elseif((strcmp(this.sfUddHandle.ChartUpdate,'DISCRETE')))
                UpdateMethod=Simulink.MATLABFunction.UpdateMethodEnum.Discrete;
            elseif((strcmp(this.sfUddHandle.ChartUpdate,'INHERITED')))
                UpdateMethod=Simulink.MATLABFunction.UpdateMethodEnum.Inherited;
            end
        end

        function set.UpdateMethod(this,chartUpdateMethod)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            if(chartUpdateMethod==Simulink.MATLABFunction.UpdateMethodEnum.Continuous)
                this.sfUddHandle.ChartUpdate='Continuous';
            elseif(chartUpdateMethod==Simulink.MATLABFunction.UpdateMethodEnum.Discrete)
                this.sfUddHandle.ChartUpdate='Discrete';
            elseif(chartUpdateMethod==Simulink.MATLABFunction.UpdateMethodEnum.Inherited)
                this.sfUddHandle.ChartUpdate='Inherited';
            end
        end


        function SampleTime=get.SampleTime(this)
            SampleTime=this.sfUddHandle.SampleTime;
        end

        function set.SampleTime(this,sampleTime)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            propertyName='SampleTime';
            errorString=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateStringProperties(...
            propertyName,sampleTime);
            if(~isempty(errorString))
                throwAsCaller(errorString);
            end

            if(strcmp(this.sfUddHandle.ChartUpdate,'CONTINUOUS')||...
                strcmp(this.sfUddHandle.ChartUpdate,'INHERITED'))




                warning off backtrace;
                warning(...
                message('Stateflow:MATLABFunctionConfiguration:WarnSampleTime'));
                warning on backtrace;
            else
                this.sfUddHandle.SampleTime=sampleTime;
            end
        end

        function SupportVariableSizing=get.SupportVariableSizing(this)
            SupportVariableSizing=this.sfUddHandle.SupportVariableSizing;
        end

        function set.SupportVariableSizing(this,supportVS)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            propertyName='SupportVariableSizing';
            errorLogical=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateLogicalProperties(...
            propertyName,supportVS);
            if(~isempty(errorLogical))
                throwAsCaller(errorLogical);
            else
                this.sfUddHandle.SupportVariableSizing=supportVS;
            end
        end


        function AllowDirectFeedthrough=get.AllowDirectFeedthrough(this)
            AllowDirectFeedthrough=this.sfUddHandle.AllowDirectFeedthrough;
        end

        function set.AllowDirectFeedthrough(this,allowDirectFeedthrough)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            propertyName='AllowDirectFeedthrough';
            errorLogical=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateLogicalProperties(...
            propertyName,allowDirectFeedthrough);
            if(~isempty(errorLogical))
                throwAsCaller(errorLogical);
            end



            if(strcmp(this.sfUddHandle.ChartUpdate,'CONTINUOUS'))



                warning off backtrace;
                warning(...
                message('Stateflow:MATLABFunctionConfiguration:WarnAllowDirectFeedthrough'));
                warning on backtrace;
            else
                this.sfUddHandle.AllowDirectFeedthrough=allowDirectFeedthrough;
            end
        end


        function VectorOutputs1D=get.VectorOutputs1D(this)
            VectorOutputs1D=this.sfUddHandle.VectorOutputs1D;
        end

        function set.VectorOutputs1D(this,vectorOutputs1D)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            propertyName='VectorOutputs1D';
            errorLogical=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateLogicalProperties(...
            propertyName,vectorOutputs1D);
            if(~isempty(errorLogical))
                throwAsCaller(errorLogical);
            end

            this.sfUddHandle.VectorOutputs1D=vectorOutputs1D;
        end


        function SaturateOnIntegerOverflow=get.SaturateOnIntegerOverflow(this)
            SaturateOnIntegerOverflow=this.sfUddHandle.SaturateOnIntegerOverflow;
        end

        function set.SaturateOnIntegerOverflow(this,saturateOnIntegerOverflow)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            propertyName='SaturateOnIntegerOverflow';
            errorLogical=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateLogicalProperties(...
            propertyName,saturateOnIntegerOverflow);
            if(~isempty(errorLogical))
                throwAsCaller(errorLogical);
            end

            this.sfUddHandle.SaturateOnIntegerOverflow=saturateOnIntegerOverflow;
        end




        function Fimath=get.Fimath(this)
            if(strcmp(this.sfUddHandle.EmlDefaultFimath,'Same as MATLAB Default'))
                Fimath='fimath(''RoundingMethod'',''Nearest'',''OverflowAction'',''Saturate'',''ProductMode'',''FullPrecision'',''SumMode'',''FillPrecision'')';
            else
                Fimath=this.sfUddHandle.InputFimath;
            end
        end

        function set.Fimath(this,inputFimath)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end
            if(isfimath(inputFimath))
                inputFimath=inputFimath.tostring();
            end
            propertyName='Fimath';
            errorString=...
            Simulink.MATLABFunction.MATLABFunctionConfiguration.validateStringProperties(...
            propertyName,inputFimath);
            if(~isempty(errorString))
                throwAsCaller(errorString);
            end
            if(strcmp(this.sfUddHandle.EmlDefaultFimath,'Same as MATLAB Default'))



                warning off backtrace;
                warning(...
                message('Stateflow:MATLABFunctionConfiguration:WarnFimath'));
                warning on backtrace;
            else
                this.sfUddHandle.InputFimath=inputFimath;
            end

        end


        function TreatAsFi=get.TreatAsFi(this)
            if(strcmp(this.sfUddHandle.TreatAsFi,'Fixed-point'))
                TreatAsFi=Simulink.MATLABFunction.TreatAsFiEnum.FixedPoint;
            elseif(strcmp(this.sfUddHandle.TreatAsFi,'Fixed-point & Integer'))
                TreatAsFi=Simulink.MATLABFunction.TreatAsFiEnum.FixedPointAndInteger;
            end
        end

        function set.TreatAsFi(this,treatAsFi)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end

            if(treatAsFi==Simulink.MATLABFunction.TreatAsFiEnum.FixedPoint)
                this.sfUddHandle.TreatAsFi='Fixed-point';
            elseif(treatAsFi==Simulink.MATLABFunction.TreatAsFiEnum.FixedPointAndInteger)
                this.sfUddHandle.TreatAsFi='Fixed-point & Integer';
            end
        end


        function FimathMode=get.FimathMode(this)
            if(strcmp(this.sfUddHandle.EmlDefaultFimath,'Other:UserSpecified'))
                FimathMode=Simulink.MATLABFunction.FimathModeEnum.UserSpecified;
            elseif(strcmp(this.sfUddHandle.EmlDefaultFimath,'Same as MATLAB Default'))
                FimathMode=Simulink.MATLABFunction.FimathModeEnum.SameAsMATLAB;
            end
        end

        function set.FimathMode(this,inputString)
            errorLinkedOrLocked=linkedOrLockedError(this);
            if(~isempty(errorLinkedOrLocked))
                throwAsCaller(errorLinkedOrLocked);
            end




            if(inputString==Simulink.MATLABFunction.FimathModeEnum.UserSpecified)
                this.sfUddHandle.EmlDefaultFimath='Other:UserSpecified';
            elseif(inputString==Simulink.MATLABFunction.FimathModeEnum.SameAsMATLAB)
                this.sfUddHandle.EmlDefaultFimath='Same as MATLAB Default';
            end
        end

        function report=getReport(this)
            hideProgressBar=false;
            genReportInfo=true;
            [~,reportInfo]=sfprivate('eml_report_manager','report',this.chartID,...
            this.blockHandle,hideProgressBar,genReportInfo);
            if~isempty(reportInfo)&&reportInfo.Summary.Success
                report=coder.MATLABFunctionReport(reportInfo.Functions);
            else
                report=coder.MATLABFunctionReport.empty();
                throwAsCaller(MException('Stateflow:misc:MLFBReportFailed',...
                message('Stateflow:misc:MLFBReportFailed',this.blockPath)));
            end
        end

        function openReport(this)
            sfprivate('eml_report_manager','open',this.chartID,this.blockHandle);
        end

        function closeReport(this)
            sfprivate('eml_report_manager','close',this.chartID,this.blockHandle);
        end

        function delete(this)
            this.blockHandle=[];
            this.chartID=[];
            this.sfUddHandle=[];
            this.blockPath=[];
        end
    end
end
