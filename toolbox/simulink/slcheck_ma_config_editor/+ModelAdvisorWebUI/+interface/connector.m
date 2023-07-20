classdef connector<handle

    properties(SetAccess=protected)
        applicationID;

        subscriptionGetSelectedTreeNode;
        subscriptionGetDisplayname;
        subscriptionIsCheckedTreeNode;
        subscriptionIsExpandedTreeNode;
        subscriptionInputParametersChannel;
        subscriptionLeafChildrenChannel;
        isLoadedChannel;
        isBusySpinningChannel;
        subscriptionGetChildren;
        subscriptionEditTimeNodes;
        SubscriptionCheckedEditTimeNodes;
        subscriptionNewFolderStatusForEditTime;
        subscriptionGetSelectedTreeNodeId;
        subscriptionexecuteJS;
        subscriptionFilePathChannel;
        subscriptionSeverityChannel;

        inputparam=[];
        nodeid=[];
        librarynodeid=[];
        nodeChildren=[];
        leafChildren=[];
        hierarchialChildren=[];
        editTimeNodes=[];
        checkValues=[];
        isexpanded=[];
        ischecked=[];
        isLoaded;
        isEnable;
        newfolder_edittime;
        displayname=[];
        actionstatus=struct();
        fileMenuStatus=struct();
        isBusySpinning;
        jsonPrettyPrint='';
        uiTitle='';
        undoRedoFlag='';
        severityOption='';
    end
    methods
        function this=connector(applicationID)
            this.applicationID=applicationID;
        end

        function cleanup(obj)
        end

        function selectTreeNode(this,nodeID)
            this.actionstatus=[];
            this.nodeid=[];
            this.inputparam=[];
            this.displayname=[];
            this.nodeChildren=[];
            this.ischecked=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            this.subscriptionInputParametersChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishgetInputParameters'),@(msg)getInputParametersResult(this,msg));
            this.subscriptionIsCheckedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishIsCheckedTreeNode'),@(msg)isCheckedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testSelectTreeNode'),nodeID);
        end



        function getSelectedNode(this)
            this.nodeid=[];
            this.subscriptionGetSelectedTreeNodeId=message.subscribe(strcat('/MACE/',this.applicationID,'/publishSelectedNodeId'),@(msg)getSelectedTreeNodeId(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/getSelectedNode'),"");
        end

        function jsonPrettyPrint=prettyPrintJSON(this,jsonString)
            this.jsonPrettyPrint='';
            this.subscriptionexecuteJS=message.subscribe(strcat('/MACE/',this.applicationID,'/executeJS'),@(msg)prettyPrintJSON(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/executeJS'),jsonString);


            for i=1:100
                pause(0.01);
                if~isempty(this.jsonPrettyPrint)
                    break;
                end
            end
            if i==100

                if ischar(jsonString)
                    jsonPrettyPrint=jsonString;
                else
                    jsonPrettyPrint=jsonencode(jsonString);
                end
            else
                jsonPrettyPrint=this.jsonPrettyPrint;
            end
        end

        function checkTreeNode(this,nodeID)
            this.ischecked=[];
            this.nodeid=[];
            this.subscriptionIsCheckedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishIsCheckedTreeNode'),@(msg)isCheckedTreeNodeResult(this,msg));
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testCheckTreeNode'),nodeID);
        end

        function uncheckTreeNode(this,nodeID)
            this.ischecked=[];
            this.nodeid=[];
            this.subscriptionIsCheckedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishIsCheckedTreeNode'),@(msg)isCheckedTreeNodeResult(this,msg));
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testUncheckTreeNode'),nodeID);
        end

        function expandTreeNode(this,nodeID)
            this.fileMenuStatus=[];
            this.subscriptionFilePathChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishFilePath'),@(msg)getFilePath(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testExpandTreeNode'),nodeID);
        end

        function collapseTreeNode(this,nodeID)
            this.fileMenuStatus=[];
            this.subscriptionFilePathChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishFilePath'),@(msg)getFilePath(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testCollapseTreeNode'),nodeID);
        end



        function toggleItemEnableStatus(this,nodeId)
            this.isEnable=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/toggleItemEnableStatus'),nodeId);
        end


        function getDisplayName(this)
            this.displayname=[];
            this.subscriptionGetDisplayname=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetDisplayName'),@(msg)getDisplayNameResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testGetDisplayName'),"");
        end

        function updateDisplayName(this)

        end

        function isExpandedTreeNode(this,nodeID)
            this.subscriptionIsExpandedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishIsExpandedTreeNode'),@(msg)isExpandedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testIsExpandedTreeNode'),nodeID);
        end

        function selectEditTime(this)
            this.checkValues=[];
            this.editTimeNodes=[];
            this.subscriptionEditTimeNodes=message.subscribe(strcat('/MACE/',this.applicationID,'/publishEditTimeNodes'),@(msg)editTimeNodesResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/selectEditTimeChannel'),"");
        end



        function getEditTimeNodes(this)
            this.editTimeNodes=[];
            this.checkValues=[];
            this.subscriptionEditTimeNodes=message.subscribe(strcat('/MACE/',this.applicationID,'/publishEditTimeNodes'),@(msg)editTimeNodesResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/getEditTimeNodes'),"");
        end

        function getCheckedEditTimeNodes(this)
            this.editTimeNodes=[];
            this.SubscriptionCheckedEditTimeNodes=message.subscribe(strcat('/MACE/',this.applicationID,'/getCheckedEditTimeNodes'),@(msg)checkedEditTimeNodesResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/getCheckedEditTimeNodes'),"");
        end

        function getNewFolderStatusForEditTime(this)
            this.subscriptionNewFolderStatusForEditTime=message.subscribe(strcat('/MACE/',this.applicationID,'/publishNewFolderStatusForEditTime'),@(msg)newFolderStatusForEditTime(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/getNewFolderStatusForEditTime'),"");
        end

        function removeTreeNode(this)
            this.nodeid=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testRemoveTreeNode'),"");
        end

        function out=getInputParameters(this)
            out=this.inputparam;
            this.subscriptionInputParametersChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishgetInputParameters'),@(msg)getInputParametersResult(this,msg));
        end

        function copyTreeNode(this)
            message.publish(strcat('/MACE/',this.applicationID,'/testCopyTreeNode'),"");
        end

        function cutTreeNode(this)
            message.publish(strcat('/MACE/',this.applicationID,'/testCutTreeNode'),"");
        end

        function pasteTreeNode(this)
            this.nodeChildren=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testPasteTreeNode'),"");
        end

        function undo(this)
            this.undoRedoFlag='';
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testundoAction'),"");
        end

        function redo(this)
            this.undoRedoFlag='';
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/testredoAction'),"");
        end

        function moveUp(this)
            this.nodeid=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/moveUpTreeNode'),"");
        end

        function moveDown(this)
            this.nodeid=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/moveDownTreeNode'),"");
        end



        function newFolder(this)
            this.nodeChildren=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/newFolder'),"");
        end



        function saveConfiguration(this,appID)
            this.uiTitle='';
            this.subscriptionFilePathChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishFilePath'),@(msg)getFilePath(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/saveConfiguration'),"");
        end

        function saveAsConfiguration(this)
            this.uiTitle='';
            this.subscriptionFilePathChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishFilePath'),@(msg)getFilePath(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/saveAsConfiguration'),"");
        end

        function openConfiguration(this)
            this.fileMenuStatus=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            this.subscriptionFilePathChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishFilePath'),@(msg)getFilePath(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/openConfiguration'),"");
        end

        function createNewConfiguration(this)



            this.actionstatus=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/testPublishGetSelectedTreeNode'),@(msg)getSelectedTreeNodeResult(this,msg));
            this.subscriptionFilePathChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishFilePath'),@(msg)getFilePath(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/createNewConfig'),"");
        end

        function getUiTitle(this)
            this.uiTitle='';
            this.subscriptionFilePathChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishFilePath'),@(msg)getFilePath(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/publishFilePath'),"");
        end

        function restoreDefaultConfiguration(this)
            message.publish(strcat('/MACE/',this.applicationID,'/restoreDefaultConfiguration'),"");
        end

        function setAsDefaultConfiguration(this)
            message.publish(strcat('/MACE/',this.applicationID,'/setAsDefaultConfiguration'),"");
        end


        function out=getNodeChildren(this)
            out=this.nodeChildren;
        end

        function getLeafOrHierarchialChildren(this,nodeID)
            this.leafChildren=[];
            this.hierarchialChildren=[];
            this.subscriptionLeafChildrenChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishgetLeafChildren'),@(msg)getLeafChildrenResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/getLeafChildren'),nodeID);
        end

        function openCloseLibrary(this)
            message.publish(strcat('/MACE/',this.applicationID,'/openLibrary'),"");
        end

        function selectNodeInLibrary(this,nodeID)
            this.actionstatus=[];
            this.librarynodeid=[];
            this.displayname=[];
            this.nodeChildren=[];
            this.subscriptionGetSelectedTreeNode=message.subscribe(strcat('/MACE/',this.applicationID,'/publishGetSelectedTreeNodeInLib'),@(msg)getSelectedTreeNodeInLibrary(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/selectNodeInLibrary'),nodeID);
        end

        function updateInputParameters(this,inputparameters,node,ip_num,value)
            this.inputparam=[];
            result=ModelAdvisorWebUI.interface.invokeInputParameterCallback(inputparameters,node,ip_num,value);
            this.subscriptionInputParametersChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishgetInputParameters'),@(msg)getInputParametersResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/updateNamingStandard'),result);
        end

        function changeSeverityOption(this,newValue)
            this.severityOption='';
            this.subscriptionSeverityChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/changeSeverity'),@(msg)getNewSeverityValue(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/changeSeverity'),newValue);
        end

        function clickOnApply(this)
            this.inputparam=[];
            this.subscriptionInputParametersChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/publishgetInputParameters'),@(msg)getInputParametersResult(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/clickOnApply'),"");
        end

        function clickOnOK(this)
            message.publish(strcat('/MACE/',this.applicationID,'/clickOnOK'),"");
        end

        function clickOnCancel(this)
            message.publish(strcat('/MACE/',this.applicationID,'/clickOnCancel'),"");
        end

        function isMACELoaded(this)
            this.isLoadedChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/isLoaded'),@(msg)isMACELoaded(this,msg));
        end

        function checkSpinning(this)
            this.isBusySpinning='';
            this.isBusySpinningChannel=message.subscribe(strcat('/MACE/',this.applicationID,'/isSpinning'),@(msg)isSpinning(this,msg));
            message.publish(strcat('/MACE/',this.applicationID,'/checkSpinning'),"");
        end

        function deleteInputParam(this)
            this.inputparam=[];
        end

        function deleteNodeId(this)
            this.nodeid=[];
        end

        function deleteChildren(this)
            this.nodeChildren=[];
        end
    end
end

function getSelectedTreeNodeResult(obj,msg)
    if(isstruct(msg.node))
        obj.nodeid=msg.node.currNode.id;
        obj.inputparam=msg.node.currNode.InputParameters;
        obj.displayname=msg.node.currNode.label;
        obj.isEnable=msg.node.currNode.enable;
    else
        obj.nodeid=msg.node;
        obj.inputparam=[];
        obj.displayname=msg.label;
    end
    obj.nodeChildren=msg.children;
    obj.actionstatus=msg.actionStatus;
    obj.undoRedoFlag=true;
    message.unsubscribe(obj.subscriptionGetSelectedTreeNode);
end

function getSelectedTreeNodeInLibrary(obj,msg)
    obj.librarynodeid=msg.node;
    obj.displayname=msg.label;
    obj.nodeChildren=msg.children;
    obj.actionstatus=msg.actionStatus;
    message.unsubscribe(obj.subscriptionGetSelectedTreeNode);
end

function prettyPrintJSON(obj,msg)
    obj.jsonPrettyPrint=msg;
    message.unsubscribe(obj.subscriptionexecuteJS);
end

function isCheckedTreeNodeResult(obj,msg)
    obj.ischecked=msg;
    message.unsubscribe(obj.subscriptionIsCheckedTreeNode);
end

function isExpandedTreeNodeResult(obj,msg)
    obj.isexpanded=msg;
    message.unsubscribe(obj.subscriptionIsExpandedTreeNode);
end

function getInputParametersResult(obj,msg)
    obj.inputparam=msg;
    message.unsubscribe(obj.subscriptionInputParametersChannel);
end

function getLeafChildrenResult(obj,msg)
    obj.leafChildren=msg.leafchildren;
    obj.hierarchialChildren=msg.children;
    message.unsubscribe(obj.subscriptionLeafChildrenChannel);
end

function editTimeNodesResult(obj,msg)
    obj.editTimeNodes=msg.nodes;
    obj.checkValues=msg.check;
    message.unsubscribe(obj.subscriptionEditTimeNodes);
end

function checkedEditTimeNodesResult(obj,msg)
    obj.editTimeNodes=msg.nodes;
    message.unsubscribe(obj.SubscriptionCheckedEditTimeNodes);
end

function newFolderStatusForEditTime(obj,msg)
    obj.newfolder_edittime=msg;
    message.unsubscribe(obj.subscriptionNewFolderStatusForEditTime);
end

function getDisplayNameResult(obj,msg)
    obj.displayname=msg;
    message.unsubscribe(obj.subscriptionGetDisplayname);
end
function isMACELoaded(obj,msg)
    obj.isLoaded=msg;
    message.unsubscribe(obj.isLoadedChannel);
end

function isSpinning(obj,msg)
    obj.isBusySpinning=msg;
    message.unsubscribe(obj.isBusySpinningChannel);
end

function getSelectedTreeNodeId(obj,msg)
    obj.nodeid=msg;
    message.unsubscribe(obj.subscriptionGetSelectedTreeNodeId);
end

function getFilePath(obj,msg)
    if(isfield(msg,'filePath'))
        obj.uiTitle=msg.filePath;
    end
    obj.fileMenuStatus=msg.fileMenuStatus;
    message.unsubscribe(obj.subscriptionFilePathChannel);
end

function getNewSeverityValue(obj,msg)
    obj.severityOption=msg;
    message.unsubscribe(obj.subscriptionSeverityChannel);
end

