function[mfunctionHandlesWithLinks,isSfMFnc]=getMFunctionsWithLinks(sfObjs)

    mfunctionHandlesWithLinks=[];
    isSfMFnc=false(size(sfObjs));

    for i=1:length(sfObjs)
        if isa(sfObjs(i),'Stateflow.EMChart')
            if rmidata.emCodeHasLinks(sfObjs(i))
                sfChartH=sf('Private','chart2block',sfObjs(i).Id);
                mfunctionHandlesWithLinks=[mfunctionHandlesWithLinks;sfChartH];%#ok<AGROW>
            end
        elseif isa(sfObjs(i),'Stateflow.EMFunction')
            if rmidata.emCodeHasLinks(sfObjs(i))
                mfunctionHandlesWithLinks=[mfunctionHandlesWithLinks;sfObjs(i).Id];%#ok<AGROW>
                sfChartH=sf('Private','chart2block',sfObjs(i).Chart.Id);
                mfunctionHandlesWithLinks=[mfunctionHandlesWithLinks;sfChartH];%#ok<AGROW>  

                isSfMFnc(i)=true;
            end
        end
    end
end
