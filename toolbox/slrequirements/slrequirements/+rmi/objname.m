function[objName,objType,objH,errMsg]=objname(obj)







    if isa(obj,'Stateflow.EMFunction')
        objName=strrep(obj.LabelString,' ','');
        objType='EMFunction';
        objH=obj.Id;
        errMsg='';
        return;
    end

    sigbGroup='';

    if rmisl.isHarnessIdString(obj)



        if~isempty(regexp(obj,':[:\d]+\.\d+','once'))

            match=regexp(obj,'^(\S)+\.(\d)+','tokens');
            if isempty(match)
                objName='undef';
                objType='undef';
                objH=[];
                return;
            else
                [isSf,objH,errMsg]=rmisl.resolveObjInHarness(match{1}{1});
                sigbGroup=match{1}{2};
            end
        else
            [isSf,objH,info]=rmisl.resolveObjInHarness(obj);
            if isempty(objH)
                objName=info;
                objType='';
                objH=[];
                return;
            end
        end
    elseif ischar(obj)&&~isempty(regexp(obj,':[:\d]+\.\d+','once'))

        match=regexp(obj,'^(\S)+\.(\d)+','tokens');
        if isempty(match)
            objName='undef';
            objType='undef';
            objH=[];
            return;
        else
            [isSf,objH,errMsg]=rmi.resolveobj(match{1}{1});
            sigbGroup=match{1}{2};
        end
    elseif sysarch.isZCPort(obj)
        objType='Port';
        objH=sysarch.getIdForLinking(obj);
        objName=sysarch.getSummary(objH,get_param(bdroot(obj),'Name'));
        return;
    elseif rmifa.isFaultInfoObj(obj)
        faultInfoObj=rmifa.resolveObjInFaultInfo(obj);
        if isa(faultInfoObj,'Simulink.fault.Fault')
            objType='Fault';
        else
            objType='Conditional';
        end
        objH=faultInfoObj;
        objName=faultInfoObj.Name;
        return;
    elseif rmism.isSafetyManagerObj(obj)
        objType='safetymanager';
        objH=obj.uuid;
        objName=obj.getFileName();
    else

        [isSf,objH,errMsg]=rmi.resolveobj(obj);
        if~isempty(errMsg)
            objName='undef';
            objType='undef';
            objH=[];
            return;
        end
    end

    if isSf
        objIsa=sf('get',objH,'.isa');
        sfisa=rmisf.sfisa;
        switch(objIsa)
        case sfisa.chart
            objType='Chart';
            objName=sf('get',objH,'.name');
        case sfisa.state
            [chartId,objName]=sf('get',objH,'.chart','.name');
            sfr=sfroot;
            chartObj=sfr.idToHandle(chartId);
            if isa(chartObj,'Stateflow.ReactiveTestingTableChart')
                objType='Step';
            else
                objType='State';
            end
            if isempty(objName)
                sidNum=sf('get',objH,'.ssIdNumber');
                objName=getString(message('Slvnv:report:UnlabeledState',num2str(sidNum)));
            end
        case sfisa.transition
            [chartId,objName]=sf('get',objH,'.chart','.labelString');

            objType='Transition';
            if Stateflow.ReqTable.internal.isRequirementsTable(chartId)

                objName=Stateflow.ReqTable.internal.TableManager.getSummaryFromObject(chartId,objH);
            end
            if isempty(objName)
                sidNum=sf('get',objH,'.ssIdNumber');
                objName=getString(message('Slvnv:report:UnlabeledTransition',num2str(sidNum)));
            end
        otherwise


            typesCells=struct2cell(sfisa);
            typesNames=fieldnames(sfisa);
            objType=typesNames{[typesCells{:}]==objIsa};
            objName=getString(message('Slvnv:rmi:resolveobj:StateflowObjectSSIdNumber',sf('get',objH,'.ssIdNumber'),objType));
            errMsg=getString(message('Slvnv:rmi:resolveobj:ObjectNotSupported',objType));
        end
    elseif sysarch.isComponent(objH)
        objName=cr2space(get_param(objH,'Name'));
        objType='Component';
    elseif sysarch.isZCPort(objH)
        objName=cr2space(get_param(objH,'Name'));
        objType='Port';


    else
        objType=rmisl.slBlockType(objH);
        if strcmp(objType,'annotation')
            objName=get(objH,'PlainText');
            if isempty(objName)





                switch get(objH,'AnnotationType')
                case 'image_annotation'
                    objName=getString(message('Slvnv:report:UnlabeledImage'));
                case 'area_annotation'
                    objName=getString(message('Slvnv:report:UnlabeledArea'));
                case 'note_annotation'

                    objName=getString(message('Slvnv:report:UnlabeledNote'));
                end
            end
        else
            objName=cr2space(get_param(objH,'Name'));
        end
        if~isempty(sigbGroup)&&strcmp(objType,'SubSystem')
            objName=sprintf('%s (group %s)',objName,sigbGroup);
            objType='SigBuilder';
        end
    end

    function out=cr2space(out)
        out(out==newline)=' ';
