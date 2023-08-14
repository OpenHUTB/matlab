classdef ReportBase<handle








    properties
        OutputFolder;
        OutputFile='report.html';
        PreventOverwritingFile=false;
        SdiEngine;
        IsBlockPathShortened=true;
        CloseAfterWriting;
    end

    properties(Access=public,Hidden=true)
        DocumentNode;

        Description;
    end

    properties(SetAccess=protected,Hidden=true)


        LineStyleMap;






        ImagesToDelete;

    end

    properties(Dependent=true)

        Columns;
    end

    properties(Hidden=true,Dependent=true)
        OutputFileName;
    end

    properties(Access=protected,Hidden=true,Dependent=true)
        IsColumnDefault;
    end

    properties(Constant=true,Hidden=true)

        ColorBlue='#2B4F81';
        ColorLightBlue='#C3DCFF';
        ColorGrey='#EBEBEB';
        ColorWhite='#FFFFFF';
        PaddingForTableCells='2px';
        StringDict=Simulink.sdi.internal.StringDict();
    end

    properties(Access=protected)
        SmartTruncator;

        MetaDataInReport;
    end

    methods


        function obj=ReportBase(sdiEngine)
            obj.SdiEngine=sdiEngine;

            obj.initLineStyleMap();
        end

        function filename=get.OutputFileName(obj)

            [~,filename,ext]=fileparts(obj.OutputFile);%#ok<*NASGU>
            if isempty(filename)
                error(message('SDI:sdi:EmptyFileNames'));
            end
        end

        function set.SdiEngine(obj,sdie)



            obj.SdiEngine=sdie;
        end

        function set.Columns(obj,columns)
            validateattributes(columns,{'Simulink.sdi.SignalMetaData'},{});
            obj.MetaDataInReport=columns;
        end

        function isColumnDefault=get.IsColumnDefault(obj)
            if isempty(obj.MetaDataInReport)
                isColumnDefault=true;
            else
                isColumnDefault=false;
            end
        end

        function columns=get.Columns(obj)
            columns=obj.getReportedColumns();
        end

        function set.DocumentNode(obj,docNode)
            assert(isa(docNode,'Simulink.sdi.internal.ReportDocument'));
            obj.DocumentNode=docNode;
        end

        function create(obj)









            import mlreportgen.*;


            if~isa(obj.SdiEngine,'Simulink.sdi.internal.Engine')
                error(message('SDI:sdi:InvalidSDIEngine'));
            end


            obj.setOutputDirFileName();



            obj.checkDependencies();



            if~isempty(obj.DocumentNode)&&~isempty(obj.DocumentNode.Children)



                assert(isa(obj.DocumentNode,'mlreportgen.dom.Document'));
                assert(strcmp(obj.OutputFileName,obj.DocumentNode.Filename));
                assert(strcmp(obj.OutputFolder,obj.DocumentNode.Filepath));
            else
                Simulink.sdi.internal.ReportDocument(obj);
            end

            obj.populateReport();


            if obj.CloseAfterWriting
                obj.close();
            end
        end

        function close(obj)
            if isa(obj.DocumentNode,'Simulink.sdi.internal.ReportDocument')
                obj.DocumentNode.close();

                images=unique(obj.ImagesToDelete);
                for i=1:length(images)
                    delete(images{i});
                end

                obj.ImagesToDelete={};

            end
        end

    end

    methods(Access=private,Hidden=true)

        function initLineStyleMap(obj)
            obj.LineStyleMap=Simulink.sdi.Map('a',?handle);


            obj.LineStyleMap.insert('-',[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
            obj.LineStyleMap.insert('--',[1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0]);
            obj.LineStyleMap.insert(':',[1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1]);
            obj.LineStyleMap.insert('-.',[1,1,1,1,1,1,1,0,0,1,1,0,0,1,1,1]);
        end

        function createImageOfLine(obj,lineStyle,lineColor,filename)

            linePattern=obj.LineStyleMap.getDataByKey(lineStyle);

            lineColor=reshape(lineColor,1,1,3);

            linePattern=repmat(linePattern,[1,1,3]);
            [r,c,d]=size(linePattern);
            lineColor=repmat(lineColor,[r,c,1]);

            im=linePattern.*lineColor;

            im(linePattern==0)=1;
            imwrite(im,filename,'png');
        end

        function imgGroup=parseImAttributes(obj,domImage,imAttributes)
            import mlreportgen.*;




            if isfield(imAttributes,'Style')
                domImage.Style=imAttributes.Style;
            end

            imgGroup=dom.Group;


            if isfield(imAttributes,'Title')
                title=dom.Paragraph(imAttributes.Title);
                append(imgGroup,title);
            end

            append(imgGroup,domImage);


            if isfield(imAttributes,'Caption')
                caption=dom.Paragraph(imAttributes.Caption);
                caption.Style='Caption';
                append(imgGroup,caption);
            end

        end
    end

    methods(Access=protected,Hidden=true,Static=true)

        function tableNode=createTableNode(table)
            import mlreportgen.*;

            tableNode=dom.Table(table);
        end

        function isTrivial=checkIfDataIsTrivial(dataNode)
            import mlreportgen.*;


            if isa(dataNode,'mlreportgen.dom.Text')
                txt=dataNode.Content;
            end

            if isa(dataNode,'mlreportgen.dom.Link')
                txt=dataNode.Children(1).Content;
            end

            isTrivial=(isempty(strtrim(txt))||...
            (str2double(txt)==0));

        end

        function addText(txt,parent,varargin)
            import mlreportgen.*;


            domText=dom.Text(txt);

            if nargin>2
                styleObj=varargin{1};
                domText.Style=styleObj;
            end

            parent.append(domText);
        end

        function addLineBreak(parent)
            import mlreportgen.*;

            domPara=dom.Paragraph('');

            parent.append(domPara);
        end

        function table=removeUnnecessaryColumns(table,isDataTrivial)

            table=table(:,logical(~isDataTrivial));
        end


        function out=isValidMetaData(metaData)
            out=false;
            if isfield(metaData,'testUnit')&&isfield(metaData,'testHarness')
                testUnit=metaData.testUnit;
                testHarness=metaData.testHarness;
                fields={'name','version','modified','solverType','fixedStep'};
                testUnitValidity=cellfun(@(x)isfield(testUnit,x),fields);
                testHarnessValidity=cellfun(@(x)isfield(testHarness,x),...
                fields);
                invalidTestUnit=find(testUnitValidity==0,1);
                invalidTestHarness=find(testHarnessValidity==0,1);
                if isempty(invalidTestUnit)&&isempty(invalidTestHarness)
                    out=true;
                end
            end
        end


        function putSystemScreenShot(p,name)
            import mlreportgen.*
            interface=Simulink.sdi.internal.Framework.getFramework();
            outputFileName=interface.createSnapshot(name,'png');
            if~isempty(outputFileName)
                p.append(dom.Image(outputFileName));
            end
        end

        function alignTableColumns(domTable,alignType)
            import mlreportgen.*;

            ncols=length(domTable.Children(1).Children);
            if ncols>0
                specs=dom.TableColSpec.empty(ncols,0);
                for c=1:ncols
                    specs(c)=dom.TableColSpec;
                    specs(c).Style={dom.HAlign(alignType{c})};
                end
                grps=dom.TableColSpecGroup.empty(1,0);
                grps(1)=dom.TableColSpecGroup;
                grps(1).Span=ncols;
                grps(1).ColSpecs=specs;
                domTable.ColSpecGroups=grps;
            end
        end

    end

    methods(Access=protected)



        function populateReport(obj)%#ok<MANU>

        end

        function checkDependencies(obj)%#ok<MANU>

        end

        function columns=getReportedColumns(obj)%#ok<MANU>
            columns={};
        end

    end

    methods(Access=protected,Hidden=true)





        function setOutputDirFileName(obj)

            if~isempty(obj.OutputFolder)&&exist(obj.OutputFolder,'dir')==0
                mkdir(obj.OutputFolder);
            end

            if obj.PreventOverwritingFile

                sameFile=dir([fullfile(obj.OutputFolder,obj.OutputFileName),'*.html']);
                sameFile={sameFile(:).name};
                numSame=length(sameFile);
                numsuffix='';

                for i=1:numSame
                    numsuffix=num2str(i);
                    fn=[obj.OutputFileName,numsuffix,'.html'];
                    n=strcmp(fn,sameFile);
                    if(isempty(n))||(~any(n))
                        break;
                    else
                        if i==numSame
                            numsuffix=num2str(i+1);
                        end
                    end
                end
                obj.OutputFile=[obj.OutputFileName,numsuffix,'.html'];
            end
        end

        function addNode(obj,node)
            import mlreportgen.*;

            if~isempty(obj.DocumentNode)
                obj.DocumentNode.append(node);
            end
        end

        function addImage(obj,filename,parent,varargin)
            import mlreportgen.*;





            domImage=dom.Image(filename);

            if nargin>3
                imgGroup=obj.parseImAttributes(domImage,varargin{:});
                append(parent,imgGroup)
            else
                append(parent,domImage);
            end

        end

        function cacheImageToDelete(obj,imagePath)
            obj.ImagesToDelete=[obj.ImagesToDelete,{imagePath}];
        end

        function[dataNode,alignment]=getLine(obj,varargin)
            import mlreportgen.*;
            alignment='center';




            signalObj=obj.SdiEngine.getSignal(varargin{:});


            lineStyle=signalObj.LineDashed;
            lineColor=signalObj.LineColor;

            fileName=sprintf('%s_Line_Signal%d.png',obj.OutputFileName,signalObj.DataID);
            fullFileName=fullfile(obj.OutputFolder,fileName);
            obj.createImageOfLine(lineStyle,lineColor,fullFileName);


            dataNode=dom.Image(fullFileName);
            dataNode.Width='20';
            dataNode.Height='4';
            dataNode=dom.Paragraph(dataNode);
            cacheImageToDelete(obj,fullFileName);
        end

        function[dataNode,alignment]=getSignalName(obj,varargin)
            import mlreportgen.*;
            alignment='left';


            signalObj=obj.SdiEngine.getSignal(varargin{:});
            signalName=strtrim(signalObj.SignalLabel);
            if isempty(signalName)
                dataNode=dom.Text('');
            else
                dataNode=dom.Text(signalName);
            end

        end

        function[dataNode,alignment]=getSignalDescription(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            if nargin>2

                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            elseif isstruct(varargin{1})

                signalID=varargin{1}.signalID1;
            else

                signalID=varargin{1};
            end

            str=strtrim(obj.SdiEngine.getSignalDescription(signalID));
            if isempty(str)
                dataNode=dom.Text('');
            else
                dataNode=dom.Text(str);
            end

        end

        function[dataNode,alignment]=getAbsTol(obj,varargin)
            import mlreportgen.*;
            alignment='right';

            if nargin>2

                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            else
                signalID=varargin{1};
            end
            absTol=obj.SdiEngine.getSignalAbsTol(signalID);
            dataNode=dom.Text(num2str(absTol));
        end

        function[dataNode,alignment]=getMaxDifference(obj,varargin)
            import mlreportgen.*;
            alignment='right';
            if nargin>2
                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            else
                signalID=varargin{1};
            end
            signalID=obj.SdiEngine.getRootComparisonSignalID(signalID);

            maxDiff=obj.SdiEngine.sigRepository.getSignalMetric(signalID,'MaxDifference');
            if isnan(maxDiff)
                dataNode=dom.Text('');
            else
                dataNode=dom.Text(num2str(maxDiff));
            end
        end

        function[dataNode,alignment]=getRelTol(obj,varargin)
            import mlreportgen.*;
            alignment='right';

            if nargin>2

                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            else
                signalID=varargin{1};
            end
            relTol=obj.SdiEngine.getSignalRelTol(signalID);
            dataNode=dom.Text(num2str(relTol));

        end

        function[dataNode,alignment]=getTimeTol(obj,varargin)
            import mlreportgen.*;
            alignment='right';

            if nargin>2

                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            else
                signalID=varargin{1};
            end
            timeTol=obj.SdiEngine.sigRepository.getSignalTimeTol(signalID);
            dataNode=dom.Text(num2str(timeTol));
        end

        function[dataNode,alignment]=getOverrideGlobalTol(obj,varargin)
            import mlreportgen.*;
            alignment='right';

            if nargin>2

                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            else
                signalID=varargin{1};
            end
            overrideGlobalTol=obj.SdiEngine.sigRepository.getSignalOverrideGlobalTol(signalID);
            if overrideGlobalTol
                dataNode=dom.Text('yes');
            else
                dataNode=dom.Text('no');
            end
        end

        function[dataNode,alignment]=getBlockPath(obj,varargin)
            import mlreportgen.*;
            alignment='left';




            signalObj=obj.SdiEngine.getSignal(varargin{:});

            origBlockPath=signalObj.BlockSource;
            blockPath=origBlockPath;


            if obj.IsBlockPathShortened
                if isempty(obj.SmartTruncator)
                    obj.SmartTruncator=Simulink.sdi.internal.SmartTruncator();
                    obj.SmartTruncator.PathFontFamily='Arial';
                    obj.SmartTruncator.PathFontSize='10pt';
                    obj.SmartTruncator.PathTableEntryWidth='40';
                    obj.SmartTruncator.PathOuterMargin=obj.PaddingForTableCells;
                end
                blockPath=obj.SmartTruncator.evaluate(blockPath);
            end

            if isempty(blockPath)
                dataNode=dom.Text('');
            else
                dataNode=dom.Text(blockPath);
            end

        end

        function[dataNode,alignment]=getDataSource(obj,varargin)
            import mlreportgen.*;
            alignment='left';


            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(signalObj.DataSource);
        end

        function[dataNode,alignment]=getBlockName(obj,varargin)
            import mlreportgen.*;
            alignment='left';


            signalObj=obj.SdiEngine.getSignal(varargin{:});
            origBlockPath=signalObj.BlockSource;
            [~,~,blockName]=Simulink.sdi.internal.Util.helperSplitString(origBlockPath);
            dataNode=dom.Text(blockName);
        end

        function[dataNode,alignment]=getTimeSeriesRoot(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(signalObj.RootSource);
        end

        function[dataNode,alignment]=getTimeSource(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(signalObj.TimeSource);
        end

        function[dataNode,alignment]=getInterpMethod(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            if nargin>2

                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            else
                signalID=varargin{1};
            end
            interpMethod=obj.SdiEngine.getSignalInterpMethod(signalID);
            dataNode=dom.Text(interpMethod);
        end

        function[dataNode,alignment]=getSyncMethod(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            if nargin>2

                signalID=obj.SdiEngine.getSignalIDByIndex(varargin{:});
            else
                signalID=varargin{1};
            end
            syncMethod=obj.SdiEngine.getSignalSyncMethod(signalID);
            dataNode=dom.Text(syncMethod);
        end

        function[dataNode,alignment]=getPort(obj,varargin)
            import mlreportgen.*;
            alignment='right';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(num2str(signalObj.PortIndex));
        end

        function[dataNode,alignment]=getDimensions(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(num2str(signalObj.SampleDims));
        end

        function[dataNode,alignment]=getChannel(obj,varargin)
            import mlreportgen.*;
            alignment='right';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(num2str(signalObj.Channel));
        end

        function[dataNode,alignment]=getRun(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            runID=signalObj.RunID;
            dataNode=dom.Text(obj.SdiEngine.getRunName(int32(runID)));
        end

        function[dataNode,alignment]=getModel(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(num2str(signalObj.ModelSource));
        end

        function[dataNode,alignment]=getSID(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(signalObj.SID);
        end

        function[dataNode,alignment]=getUnit(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            dataNode=dom.Text(signalObj.Units);
        end

        function[dataNode,alignment]=getSigDataType(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            str=obj.SdiEngine.sigRepository.getSignalDataTypeLabel(signalObj.DataID);
            dataNode=dom.Text(str);
        end

        function[dataNode,alignment]=getSigComplexity(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            props=obj.SdiEngine.getSignal(varargin{:});
            sig=Simulink.sdi.getSignal(props.DataID);
            str=char(sig.Complexity);
            dataNode=dom.Text(str);
        end

        function[dataNode,alignment]=getSigComplexFormat(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            props=obj.SdiEngine.getSignal(varargin{:});
            sig=Simulink.sdi.getSignal(props.DataID);
            str=char(sig.ComplexFormat);
            dataNode=dom.Text(str);
        end

        function[dataNode,alignment]=getSigDisplayScaling(obj,varargin)
            import mlreportgen.*;
            alignment='right';
            props=obj.SdiEngine.getSignal(varargin{:});
            sig=Simulink.sdi.getSignal(props.DataID);
            str=num2str(sig.DisplayScaling);
            dataNode=dom.Text(str);
        end

        function[dataNode,alignment]=getSigDisplayOffset(obj,varargin)
            import mlreportgen.*;
            alignment='right';
            props=obj.SdiEngine.getSignal(varargin{:});
            sig=Simulink.sdi.getSignal(props.DataID);
            str=num2str(sig.DisplayOffset);
            dataNode=dom.Text(str);
        end

        function[dataNode,alignment]=getSigSampleTime(obj,varargin)
            import mlreportgen.*;
            alignment='left';

            signalObj=obj.SdiEngine.getSignal(varargin{:});
            str=obj.SdiEngine.getSignalSampleTimeLabel(signalObj.DataID);
            dataNode=dom.Text(str);
        end


        function helperPutVersionDetails(obj,p,tUnit)
            import mlreportgen.*;

            sd=Simulink.sdi.internal.StringDict;
            singleBreak=sprintf('\n');

            label=dom.Text([sd.system,': ']);
            label.Style='TestLabel';
            p.append(label);
            testUnitName=tUnit.name;
            testUnitNameText=dom.Text([testUnitName,singleBreak]);
            testUnitNameText.Style='TestValue';
            p.append(testUnitNameText);


            label=dom.Text([sd.version,': ']);
            label.Style='TestLabel';
            p.append(label);
            testUnitVersion=tUnit.version;
            testUnitVersionText=dom.Text([testUnitVersion,singleBreak]);
            testUnitVersionText.Style='TestValue';
            p.append(testUnitVersionText);


            label=dom.Text([sd.lastModified,': ']);
            label.Style='TestLabel';
            p.append(label);
            testUnitModified=tUnit.modified;
            testUnitModifiedText=dom.Text([testUnitModified,singleBreak]);
            testUnitModifiedText.Style='TestValue';
            p.append(testUnitModifiedText);


            label=dom.Text([sd.solverType,': ']);
            label.Style='TestLabel';
            p.append(label);
            testUnitSolverType=tUnit.solverType;
            testUnitSolverTypeText=dom.Text([testUnitSolverType,singleBreak]);
            testUnitSolverTypeText.Style='TestValue';
            p.append(testUnitSolverTypeText);


            label=dom.Text([sd.solver,': ']);
            label.Style='TestLabel';
            p.append(label);
            testUnitSolver=tUnit.solverName;
            testUnitSolverText=dom.Text([testUnitSolver,singleBreak]);
            testUnitSolverText.Style='TestValue';
            p.append(testUnitSolverText);


            label=dom.Text([sd.fixedStep,': ']);
            label.Style='TestLabel';
            p.append(label);
            testUnitFixedStep=tUnit.fixedStep;
            testUnitFixedStepText=dom.Text([testUnitFixedStep,singleBreak]);
            testUnitFixedStepText.Style='TestValue';
            p.append(testUnitFixedStepText);
        end

        function p=putVersionDetails(obj,p,metaData)
            import mlreportgen.*;
            if obj.isValidMetaData(metaData)

                sd=Simulink.sdi.internal.StringDict;

                p.append(dom.Text(sprintf('\n\n')));

                testUnitLabel=dom.Text([sd.testUnit,sprintf('\n\n')]);
                testUnitLabel.Style='TestUnitLabel';
                p.append(testUnitLabel);
                tUnit=metaData.testUnit;

                obj.helperPutVersionDetails(p,tUnit);
                obj.putSystemScreenShot(p,tUnit.name);

                p.append(dom.Text(sprintf('\n')));

                testHarnessLabel=dom.Text([sd.testHarness,sprintf('\n\n')]);
                testHarnessLabel.Style='TestUnitLabel';
                p.append(testHarnessLabel);
                tHarness=metaData.testHarness;

                obj.helperPutVersionDetails(p,tHarness);
                obj.putSystemScreenShot(p,tHarness.name);
                p.append(dom.Text(sprintf('\n\n')));
            end
        end

    end

end


