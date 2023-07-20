function checkStateflowOnTop(this)

    slbh=get_param(this.getStartNodeName,'handle');
    if isprop(get_param(slbh,'Object'),'BlockType')&&...
        strcmpi(get_param(slbh,'BlockType'),'SubSystem')&&...
        ~strcmpi(get_param(slbh,'SFBlockType'),'NONE')
        if sfprivate('is_truth_table_chart_block',slbh)
            kind='Truth Table';
        elseif sfprivate('is_eml_chart_block',slbh)
            kind='MATLAB Function Block';
        elseif sfprivate('is_reactive_testing_table_chart_block',slbh)
            kind='Test Sequence Block';
        else
            kind='Stateflow Chart';
        end
        if strcmp(kind,'MATLAB Function Block')&&strcmp(hdlfeature('HDLBlockAsDUT'),'on')

            this.AllowBlockAsDUT=true;
        else
            error(message('hdlcoder:validate:TopLevelSF',kind));
        end
    end
end
