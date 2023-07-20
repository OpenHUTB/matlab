


function[typename,name]=getSfTypeName(pathname)

    hObj=sfprivate('ssIdToHandle',pathname);
    name='';
    switch class(hObj)
    case 'Stateflow.State'
        typename=DAStudio.message('RTW:report:State');
        name=hObj.Name;
    case 'Stateflow.TruthTable'
        typename=DAStudio.message('RTW:report:TruthTable');
        name=hObj.Name;
    case 'Stateflow.EMFunction'
        typename=DAStudio.message('RTW:report:MATLABFunction');
        name=hObj.Name;
    case 'Stateflow.Transition'
        if sf('get',hObj.Id,'.autogen.isAutoCreated')
            src=sf('get',hObj.Id,'.autogen.source');
            if sfprivate('is_truth_table_fcn',src)
                typename=DAStudio.message('RTW:report:TruthTable');
                name=sf('get',src,'.name');
            else
                typename=DAStudio.message('RTW:report:Transition');
            end
        else
            typename='Transition';
        end
    case 'Stateflow.Function'
        typename=DAStudio.message('RTW:report:Function');
        name=hObj.Name;
    case 'Stateflow.SLFunction'
        typename=DAStudio.message('RTW:report:SLFunction');
        name=hObj.Name;
    otherwise
        [~,typename]=strtok(class(hObj),'.');
        if~isempty(typename)
            typename=typename(2:end);
        end
    end
