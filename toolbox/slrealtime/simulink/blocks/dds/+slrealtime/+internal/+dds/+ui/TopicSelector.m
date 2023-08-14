classdef TopicSelector<handle







    properties
Sldd
    end

    properties(SetAccess=protected)
        DDSTopic=''
        XMLPath='Auto'
        QoS='Default'
        TopicList={}
        XMLPathList={'Auto'}
        QosList={'Default'}
        CloseFcnHandle=function_handle.empty
BlockType
ModelName
        Dlg=[]

        OldTopic=''
        OldTopicIdx=0
        OldXmlPath=''
        OldXmlPathIdx=0
        OldQos=''
        OldQosIdx=0
    end

    methods(Access=protected)
        function setTopicListAndTypes(obj)

            if isempty(obj.Sldd)
                obj.TopicList={};
                obj.XMLPathList={'Auto'};
                obj.XMLPath='Auto';
                obj.QosList={'Default'};
            else
                obj.TopicList=slrealtime.internal.dds.utils.getAllTopicsFromDictionary(obj.ModelName);
                if numel(obj.TopicList)>0
                    topicIdx=find(ismember(obj.TopicList,obj.OldTopic));
                    if~isempty(topicIdx)
                        obj.OldTopicIdx=topicIdx-1;
                        obj.DDSTopic=obj.TopicList{topicIdx};
                    else
                        obj.DDSTopic=obj.TopicList{1};
                    end
                else
                    obj.TopicList={};
                    obj.XMLPath='Auto';
                    obj.QosList={'Default'};
                end

                if strcmp(obj.BlockType,'DataReader')
                    xmlpaths=dds.internal.simulink.getDataReaders(obj.ModelName,obj.DDSTopic);
                else
                    xmlpaths=dds.internal.simulink.getDataWriters(obj.ModelName,obj.DDSTopic);
                end
                if~isempty(xmlpaths)


                    obj.XMLPathList=[{'Auto'};xmlpaths];

                    xmlIdx=find(ismember(obj.XMLPathList,obj.OldXmlPath));
                    if~isempty(xmlIdx)
                        obj.OldXmlPathIdx=xmlIdx-1;
                        obj.XMLPath=obj.XMLPathList{xmlIdx};
                    else
                        obj.XMLPath=obj.XMLPathList{1};
                    end
                else
                    obj.XMLPathList={'Auto'};
                    obj.XMLPath=obj.XMLPathList{1};
                end

                if strcmp(obj.XMLPath,'Auto')

                    if strcmp(obj.BlockType,'DataReader')
                        qoslist=dds.internal.simulink.getDataReaderQOS(obj.ModelName);
                    else
                        qoslist=dds.internal.simulink.getDataWriterQOS(obj.ModelName);
                    end
                    if~isempty(qoslist)


                        obj.QosList=[{'Default'},qoslist];
                    else
                        obj.QosList={'Default'};
                    end
                    qosIdx=find(ismember(obj.QosList,obj.OldQos));
                    if~isempty(qosIdx)
                        obj.OldQosIdx=qosIdx-1;
                        obj.QoS=obj.QosList{qosIdx};
                    else
                        obj.QoS=obj.QosList{1};
                    end
                else

                    ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(obj.ModelName);
                    if strcmp(obj.BlockType,'DataReader')
                        dataReaderWriter=dds.internal.simulink.getDataReader(obj.ModelName,obj.XMLPath);
                    else
                        dataReaderWriter=dds.internal.simulink.getDataWriter(obj.ModelName,obj.XMLPath);
                    end

                    if isempty(dataReaderWriter.QosRef)
                        obj.QosList={'Default'};
                    else
                        qosPath=dds.internal.simulink.Util.getQoSPath(ddsMf0Model,dataReaderWriter.QosRef);
                        obj.QosList={qosPath};
                    end
                    obj.QoS=obj.QosList{1};
                end
            end


        end
    end

    methods
        function obj=TopicSelector(type,blk)
            obj.BlockType=type;
            obj.ModelName=bdroot(blk);
            obj.Sldd=get_param(obj.ModelName,'DataDictionary');
        end
        function setExistingValues(obj,topicPath,xmlPath,qos)

            obj.OldTopic=topicPath;
            obj.OldXmlPath=xmlPath;
            obj.OldQos=qos;
        end
        function dlg=openDialog(obj,closeFcnHandle)






            validateattributes(closeFcnHandle,{'function_handle'},{'scalar'});
            obj.CloseFcnHandle=closeFcnHandle;
            setTopicListAndTypes(obj);
            dlg=DAStudio.Dialog(obj);
            obj.Dlg=dlg;
            dlg.setWidgetValue('ddstopiclist',obj.OldTopicIdx);
            dlg.setWidgetValue('xmlpaths',obj.OldXmlPathIdx);
            dlg.setWidgetValue('ddsqoslist',obj.OldQosIdx);
        end
    end



    methods(Hidden)

        function dlgTopicCallback(obj,dlg,tag,value)%#ok<INUSL>
            obj.DDSTopic=obj.TopicList{value+1};

            if strcmp(obj.BlockType,'DataReader')
                xmlpaths=dds.internal.simulink.getDataReaders(obj.ModelName,obj.DDSTopic);
                qoslist=dds.internal.simulink.getDataReaderQOS(obj.ModelName);
            else
                xmlpaths=dds.internal.simulink.getDataWriters(obj.ModelName,obj.DDSTopic);
                qoslist=dds.internal.simulink.getDataWriterQOS(obj.ModelName);
            end
            if~isempty(xmlpaths)
                obj.XMLPathList=[{'Auto'};xmlpaths];
            else
                obj.XMLPathList={'Auto'};
            end
            obj.XMLPath=obj.XMLPathList{1};

            if~isempty(qoslist)


                obj.QosList=[{'Default'},qoslist];
            else
                obj.QosList={'Default'};
            end
            obj.QoS=obj.QosList{1};

            dlg.refresh;
        end


        function dlgXMLPathCallback(obj,dlg,tag,value)%#ok<INUSL>
            obj.XMLPath=obj.XMLPathList{value+1};
            if strcmp(obj.XMLPath,'Auto')

                if strcmp(obj.BlockType,'DataReader')
                    qoslist=dds.internal.simulink.getDataReaderQOS(obj.ModelName);
                else
                    qoslist=dds.internal.simulink.getDataWriterQOS(obj.ModelName);
                end
                if~isempty(qoslist)


                    obj.QosList=[{'Default'},qoslist];
                else
                    obj.QosList={'Default'};
                end
                obj.QoS=obj.QosList{1};
            else

                ddsMf0Model=dds.internal.simulink.Util.getMf0ModelFromSimulinkModel(obj.ModelName);
                if strcmp(obj.BlockType,'DataReader')
                    dataReaderWriter=dds.internal.simulink.getDataReader(obj.ModelName,obj.XMLPath);
                else
                    dataReaderWriter=dds.internal.simulink.getDataWriter(obj.ModelName,obj.XMLPath);
                end

                if isempty(dataReaderWriter.QosRef)
                    obj.QosList={'Default'};
                else
                    qosPath=dds.internal.simulink.Util.getQoSPath(ddsMf0Model,dataReaderWriter.QosRef);
                    obj.QosList={qosPath};
                end
                obj.QoS=obj.QosList{1};
            end
            dlg.refresh;
        end



        function dlgQosCallback(obj,dlg,tag,value)%#ok<INUSL>
            obj.QoS=obj.QosList{value+1};
            dlg.refresh;
        end

        function dlgClose(obj,closeaction)


            if~isempty(obj.CloseFcnHandle)
                isAcceptedSelection=strcmpi(closeaction,'ok');
                try
                    feval(obj.CloseFcnHandle,isAcceptedSelection,obj.DDSTopic,obj.XMLPath,obj.QoS);
                catch



                end
            end
        end


        function dlgstruct=getDialogSchema(obj)

            msglist(1).Name=getString(message('slrealtime:dds:selectTopic'));
            msglist(1).Type='combobox';
            msglist(1).Entries=obj.TopicList;
            msglist(1).Tag='ddstopiclist';
            msglist(1).MultiSelect=false;
            msglist(1).ObjectMethod='dlgTopicCallback';
            msglist(1).MethodArgs={'%dialog','%tag','%value'};
            msglist(1).ArgDataTypes={'handle','string','mxArray'};
            msglist(1).Value=0;
            msglist(1).NameLocation=2;

            msglist(2).Name=getString(message('slrealtime:dds:selectXML',obj.BlockType));
            msglist(2).Type='combobox';
            msglist(2).Entries=obj.XMLPathList;
            msglist(2).Tag='xmlpaths';
            msglist(2).MultiSelect=false;
            msglist(2).ObjectMethod='dlgXMLPathCallback';
            msglist(2).MethodArgs={'%dialog','%tag','%value'};
            msglist(2).ArgDataTypes={'handle','string','mxArray'};
            msglist(2).Value=0;
            msglist(2).NameLocation=2;

            msglist(3).Name=getString(message('slrealtime:dds:selectQoS'));
            msglist(3).Type='combobox';
            msglist(3).Entries=obj.QosList;
            msglist(3).Tag='ddsqoslist';
            msglist(3).MultiSelect=false;
            msglist(3).ObjectMethod='dlgQosCallback';
            msglist(3).MethodArgs={'%dialog','%tag','%value'};
            msglist(3).ArgDataTypes={'handle','string','mxArray'};
            msglist(3).Value=0;
            msglist(3).NameLocation=2;




            dlgstruct.DialogTitle=getString(message('slrealtime:dds:topicSelectorDlgTitle'));
            dlgstruct.CloseMethod='dlgClose';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};



            dlgstruct.Sticky=true;




            dlgstruct.StandaloneButtonSet=...
            {'Ok','Cancel'};

            dlgstruct.Items={msglist(1),msglist(2),msglist(3)};
        end
    end
end