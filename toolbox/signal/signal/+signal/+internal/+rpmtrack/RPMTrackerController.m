classdef RPMTrackerController<handle
    properties(Access={?matlab.unittest.TestCase},Hidden)
Parent
View
Model

TimeFormat
IsSingle
IsTimeTable

NumOutputArguments
OutputArgumentNames

RHSFunctionCall
FsArgName
OrderArgName
RidgePointArgName
    end

    properties(Constant,Hidden)
        NVPString=['...\n''Method'',''%s'',',...
        '...\n''FrequencyResolution'',%.4f,',...
        '...\n''PowerPenalty'',%.4f,',...
        '...\n''FrequencyPenalty'',%.4f,',...
        '...\n''StartTime'',%.4f,',...
        '...\n''EndTime'',%.4f);'];
    end

    methods
        function this=RPMTrackerController(parent,opts)
            this.Parent=parent;
            this.View=parent.View;
            this.Model=parent.Model;

            this.TimeFormat=opts.TimeFormat;
            this.IsSingle=opts.IsSingle;
            this.IsTimeTable=opts.IsTimeTable;
            this.NumOutputArguments=opts.NumOutputArguments;
            this.OutputArgumentNames=opts.OutputArgumentNames;
            this.RHSFunctionCall=opts.RHSFunctionCallWithValueOnlyParam;
            this.FsArgName=opts.FsArgName;
            this.OrderArgName=opts.OrderArgName;
            this.RidgePointArgName=opts.RidgePointArgName;
        end
    end

    methods(Access={?signal.internal.rpmtrack.RPMTrackerView},Hidden)
        function computeMapAndUpdatePlot(this)
            this.View.setDirty(true);

            this.View.setToolgroupWaiting(true);


            this.getAndSetProperties('computeMap');


            this.Model.computeMap();


            this.View.setMap(...
            this.Model.MapTimeVector,...
            this.Model.MapFrequencyVector,...
            this.Model.MapPower);

            this.View.updateMapAndColorbarAxes();


            this.View.updateMapAxesUnits();


            this.View.updateCrosshairReadout();



            this.Model.EstimatedRPM=[];
            this.Model.OutputTimeVector=[];
            this.View.clearRPMAxesAndRidgeLine();


            this.View.bringVerticalCrosshairIntoActiveRegion();


            this.View.setToolgroupWaiting(false);
        end

        function computeRPMAndUpdatePlot(this)
            this.View.setDirty(true);



            this.View.setEstimateButtonEnabled(false);



            this.View.setToolgroupWaiting(true);


            this.getAndSetProperties('computeRPM');


            this.Model.computeRPM();


            this.View.setRpm(this.Model.EstimatedRPM,this.Model.OutputTimeVector)

            this.View.updateRPMAxesAndRidgeLine();


            this.View.setExportButtonEnabled(true);


            this.View.setToolgroupWaiting(false);

        end


        function setModelProperties(this,sel,em,fres,varargin)




            this.Model.Method=em;

            this.Model.FrequencyResolution=fres;

            if strcmpi(sel,'computeRPM')


                this.Model.Order=varargin{1};

                this.Model.RidgePoint=varargin{2};


                this.Model.PowerPenalty=varargin{3};

                this.Model.FrequencyPenalty=varargin{4};

                this.Model.StartTime=varargin{5};

                this.Model.EndTime=varargin{6};
            end
        end

        function getAndSetProperties(this,sel)
            if strcmpi(sel,'computeMap')
                [em,fres]=this.View.getPropertiesFromView('computeMap');
                this.setModelProperties('computeMap',em,fres);
            else
                [em,fres,o,pnt,ppen,fpen,st,et]=...
                this.View.getPropertiesFromView('computeRPM');
                this.setModelProperties('computeRPM',em,fres,o,pnt,ppen,...
                fpen,st,et);
            end
        end

        function onExportPushed(this)
            this.View.setStatusTextAndIcon(...
            getString(message('signal:rpmtrack:exportToWSMsg')),...
            'info','west')
            outTimeVecToWS=this.Model.OutputTimeVector;
            estRPMToWS=this.Model.EstimatedRPM;

            if this.IsSingle
                outTimeVecToWS=single(outTimeVecToWS);
            end
            if this.IsTimeTable
                outTimeVecToWS=duration(0,0,...
                outTimeVecToWS,'Format',this.TimeFormat);
                estRPMToWS=timetable(outTimeVecToWS,estRPMToWS);
            end
            if((this.NumOutputArguments>0)&&...
                ~this.Parent.IsExportButtonPushed)


                this.Parent.EstimatedRPMToWS=estRPMToWS;
                this.Parent.OutputTimeVectorToWS=outTimeVecToWS;
                this.Parent.IsExportButtonPushed=true;
            else



                outVarName=this.OutputArgumentNames;
                outVarName=regexprep(outVarName,{'[',']'},'');
                outVarName=strsplit(outVarName,',');
                if(this.NumOutputArguments==0)


                    assignin('base',outVarName{1},estRPMToWS);
                    assignin('base',outVarName{2},outTimeVecToWS);
                elseif(this.NumOutputArguments==1)

                    assignToWS(outVarName{1},estRPMToWS);
                elseif(this.NumOutputArguments==2)

                    assignToWS(outVarName{1},estRPMToWS);
                    assignToWS(outVarName{2},outTimeVecToWS);
                end
            end
        end

        function onGenerateMLScriptPushed(this)

            [method,freqRes,order,ridgePoint,powPen,freqPen,startTime,endTime]=...
            this.View.getPropertiesFromView('computeRPM');


            dateTimeStr=char(datetime('now'));
            mlVer=ver('matlab');
            sptVer=ver('signal');
            preambleStr=['%% MATLAB Code from rpmtrack GUI\n\n',...
            '%% Generated by ',mlVer.Name,' ',mlVer.Version,' and ',...
            sptVer.Name,' ',sptVer.Version,newline,newline,...
            '%% Generated on ',dateTimeStr,newline];


            mcode=sigcodegen.mcodebuffer;
            mcode.addcr(sprintf(preambleStr));


            if~this.IsTimeTable
                mcode.addcr('% Set sample rate');
                mcode.addcr([this.FsArgName,' = ',...
                num2str(this.Model.Fs,'%.4f'),';']);
            end


            mcode.addcr('% Set order of ridge of interest');
            mcode.addcr([this.OrderArgName,' = ',num2str(order,'%.4f'),';']);


            numRidgePoint=size(ridgePoint,1);
            mcode.addcr('% Set ridge points on ridge of interest');
            ridgePointNumStr=[this.RidgePointArgName,' = [...'];
            for np=1:numRidgePoint
                if np<numRidgePoint
                    ridgePointNumStr=[ridgePointNumStr,...
                    sprintf('\n%.4f %.4f;...',ridgePoint(np,1),...
                    ridgePoint(np,2))];%#ok
                else

                    ridgePointNumStr=[ridgePointNumStr,...
                    sprintf('\n%.4f %.4f];',ridgePoint(np,1),...
                    ridgePoint(np,2))];%#ok
                end
            end
            mcode.addcr(ridgePointNumStr);


            outVarName=this.OutputArgumentNames;


            mcode.addcr('% Estimate RPM');
            funcCall=[outVarName,' = ',this.RHSFunctionCall];
            funcCall=[funcCall,sprintf(this.NVPString,...
            method,freqRes,powPen,freqPen,startTime,endTime)];
            mcode.addcr(funcCall);

            pause(0.3);
            if(matlab.desktop.editor.isEditorAvailable)

                editorDoc=matlab.desktop.editor.newDocument;
                editorDoc.Text=mcode.string;
                editorDoc.smartIndentContents();

                editorDoc.goToLine(1);
            else

                disp(mcode.string);
            end
        end

    end
end




function assignToWS(outName,outVal)
    validOutName=matlab.lang.makeValidName(outName);
    listVarInWS=evalin('base','who');
    uniqueValidOutName=matlab.lang.makeUniqueStrings(validOutName,listVarInWS);
    assignin('base',uniqueValidOutName,outVal);
    tmpUVON=matlab.lang.makeUniqueStrings('uniqueValidOutName',listVarInWS);
    assignin('base',tmpUVON,uniqueValidOutName);
    addedVarToWS1=setxor(listVarInWS,evalin('base','who'));
    evalin('base',[outName,' = ',uniqueValidOutName,';']);
    addedVarToWS2=setxor(listVarInWS,evalin('base','who'));
    excludeVarToWS=setxor(addedVarToWS1,addedVarToWS2);
    addedVarToWS2=setxor(addedVarToWS2,excludeVarToWS);
    for n=1:numel(addedVarToWS2)
        evalin('base',['clear(''',addedVarToWS2{n},''')']);
    end
end
