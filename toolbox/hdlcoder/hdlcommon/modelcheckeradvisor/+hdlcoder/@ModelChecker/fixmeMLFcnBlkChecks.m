
function ResultDescription=fixmeMLFcnBlkChecks(mdlTaskObj)









    ruleName='runMLFcnBlkChecks';
    mdlAdvObj=mdlTaskObj.MAObj;
    partiallyQualifiedCheckName=ruleName;
    UserData=mdlAdvObj.UserData(partiallyQualifiedCheckName);
    checker=UserData{1};



    function fixHDLFimath(chart)
        chart.EmlDefaultFimath='Other:UserSpecified';
        chart.InputFimath='fimath(''RoundingMethod'', ''Floor'',''OverflowAction'', ''Wrap'',''ProductMode'', ''FullPrecision'', ''SumMode'', ''FullPrecision'')';
    end


    function fixSaturateOnIntegerOverflow(emchart)
        emchart.SaturateOnIntegerOverflow=0;
    end


    function flag=isHDLFimathSetting(chart)
        flag=true;
        if~strcmp(chart.EmlDefaultFimath,'Other:UserSpecified')
            flag=false;
            return;
        end
        try
            inputfiMath=eval(emchart(i).InputFimath);
        catch me
            inputfiMath=evalin('base',emchart(i).InputFimath);
        end

        fi_string=lower(tostring(inputfiMath));

        if~contains(fi_string,'floor')
            flag=false;
        end
        if~contains(fi_string,'wrap')
            flag=false;
        end
        fi_split=strsplit(fi_string,',');
        prod_mode_exists=find(not(~contains(fi_split,'productmode')));
        sum_mode_exists=find(not(~contains(fi_split,'summode')));
        if~isempty(prod_mode_exists)
            prec=fi_split{prod_mode_exists+1};
            if~contains(prec,'''fullprecision''')
                flag=false;
            end
        else
            flag=false;
        end
        if~isempty(sum_mode_exists)
            sum=fi_split{sum_mode_exists+1};
            if~contains(sum,'''fullprecision''')
                flag=false;
            end
        else
            flag=false;
        end
    end


    fixedBlocks={};



    model=checker.m_sys;
    dut=checker.m_DUT;
    rt=sfroot;
    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',model);
    emchart=m.find('-isa','Stateflow.EMChart');


    List=ModelAdvisor.List;
    List.setType('bulleted');
    for i=1:numel(emchart)
        fixed=false;
        if isempty(regexp(emchart(i).Path,sprintf('^%s/',dut),'once'))
            continue;
        end
        if~isHDLFimathSetting(emchart(i))
            fixHDLFimath(emchart(i));
            fixed=true;
        end
        if emchart(i).SaturateOnIntegerOverflow
            fixSaturateOnIntegerOverflow(emchart(i));
            fixed=true;
        end
        if fixed

            txtObjAndLink=ModelAdvisor.Text(emchart(i).Path);
            as_numeric_string=['char([',num2str(emchart(i).Path+0),'])'];
            txtObjAndLink.setHyperlink(['matlab: hilite_system(',as_numeric_string,')']);
            List.addItem(txtObjAndLink);
            fixedBlocks{end+1}=[emchart(i).Name,' was updated'];%#ok<AGROW>
        end

    end

    ResultDescription=[ModelAdvisor.Text('Following blocks were modified:'),List];
end
