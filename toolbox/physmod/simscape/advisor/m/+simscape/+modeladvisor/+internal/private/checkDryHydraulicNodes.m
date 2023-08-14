function obj=checkDryHydraulicNodes(objType)







    checkId='checkDryHydraulicNodes';


    obj=simscape.modeladvisor.internal.create_basic_check(...
    objType,checkId,...
    @checkDryHydraulicNodesCallback,...
    context='PostCompile',...
    checkedByDefault=false);
end



function msg=getMessage(id)



    messageCatalog='physmod:simscape:advisor:modeladvisor:checkDryHydraulicNodes';

    msg=DAStudio.message([messageCatalog,':',id]);
end


function result=checkDryHydraulicNodesCallback(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    result={};

    ft=ModelAdvisor.FormatTemplate('TableTemplate');

    ft.setSubBar(0);


    if strcmp(bdroot(system),system)~=true
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:ReportNotModelRootLevel'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:engine:ReportNotModelRootLevelRecAction'));
        result{end+1}=ft;
        return;
    end

    try

        dryNodes=simscape.compiler.sli.internal.finddryhydraulicnodes(...
        system,false);
    catch ME
        switch ME.identifier
        case 'physmod:simscape:compiler:sli:BadSolver'
            ft.setSubResultStatus('Warn');
            ft.setSubResultStatusText(getMessage('UnsupportedNetwork'));
            ft.setRecAction(getMessage('UnsupportedNetworkAction'));
            result{end+1}=ft;
            return;
        otherwise
            rethrow(ME);
        end
    end
    ft.setCheckText(getMessage('CheckText'));

    if~isempty(dryNodes)




        terminalCnt=cellfun(@numel,{dryNodes.terminals});
        [~,idx]=sort(terminalCnt,'descend');
        dryNodes=dryNodes(idx);

        setColTitles(ft,{'','Block','Port'});

        for i=1:numel(dryNodes)
            firstColumn=[getMessage('DryNodeLabel'),':'];
            for j=1:numel(dryNodes(i).terminals)




                blockLink=mkLink(dryNodes(i).terminals(j).block,...
                dryNodes(i).terminals(j).block,...
                dryNodes(i).terminals(j).port);

                addRow(ft,{firstColumn,blockLink,dryNodes(i).terminals(j).port});
                firstColumn='';
            end

            if i~=numel(dryNodes)
                addRow(ft,{'','',''});
            end
        end

        ft.setSubResultStatusText({getMessage('CheckResultWarn')});
        ft.setSubResultStatus('Warn');
        ft.setRecAction(getMessage('CheckResultAction'));
        mdladvObj.setCheckResultStatus(false);
    else
        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText(getMessage('CheckResultPass'));
        mdladvObj.setCheckResultStatus(true);
    end

    result{end+1}=ft;

end



function maText=mkLink(text,blocks,ports)

    text=regexprep(text,{'<','>','"'},{'&lt;','&gt;','&quot;'});



    textLimit=40;
    if(length(text)>textLimit)

        slashIndex=strfind(text,'/');
        if isempty(slashIndex)
            maText=ModelAdvisor.Text(['....',text(end-textLimit+1:end)]);
        else
            truncatedPath='';
            for i=1:length(slashIndex)
                if length(text)-slashIndex(i)<=textLimit
                    truncatedPath=text(slashIndex(i)+1:end);
                    break
                end
            end
            if isempty(truncatedPath)
                truncatedPath=['....',text(end-textLimit+1:end)];
            else
                truncatedPath=['..../',truncatedPath];
            end
            maText=ModelAdvisor.Text(truncatedPath);
        end
    else
        maText=ModelAdvisor.Text(text);
    end

    if nargin>1


        sids=Simulink.ID.getSID(blocks);
        if~iscell(sids)
            sids={sids};
        end
        if~iscell(ports)
            ports={ports};
        end

        setHyperlink(maText,['matlab:simscape.internal.highlightSLStudio('...
        ,'{',sprintf('''%s'' ',sids{:}),'},'...
        ,'{',sprintf('''%s'' ',ports{:}),'}'...
        ,')']);
    end
end
