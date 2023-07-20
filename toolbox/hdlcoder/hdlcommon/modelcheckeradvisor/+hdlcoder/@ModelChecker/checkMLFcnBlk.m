function flag=checkMLFcnBlk(this)








    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;
    rt=sfroot;


    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',model);
    emchart=m.find('-isa','Stateflow.EMChart');





    for i=1:numel(emchart)
        if isempty(regexp(emchart(i).Path,sprintf('^%s/',dut),'once'))
            continue;
        end
        fi_setting{i}=emchart(i).EmlDefaultFimath;%#ok<AGROW>
        if strcmp(fi_setting{i},'Same as MATLAB Default')
            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_Default_Fimath'));
            flag=false;
        end
    end

    for i=1:numel(emchart)
        if isempty(regexp(emchart(i).Path,sprintf('^%s/',dut),'once'))
            continue;
        end
        if strcmp(emchart(i).EmlDefaultFimath,'Other:UserSpecified')
            try
                inputfiMath=eval(emchart(i).InputFimath);
            catch me
                inputfiMath=evalin('base',emchart(i).InputFimath);
            end

            fi_string=lower(tostring(inputfiMath));
            if~contains(fi_string,'floor')
                this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_fimath_roundmode'));
                flag=false;
            end
            if~contains(fi_string,'wrap')
                this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_fimath_overflowmode'));
                flag=false;
            end
            fi_split=strsplit(fi_string,',');
            prod_mode_exists=find(not(~contains(fi_split,'productmode')));
            sum_mode_exists=find(not(~contains(fi_split,'summode')));
            if~isempty(prod_mode_exists)
                prec=fi_split{prod_mode_exists+1};
                if~contains(prec,'''fullprecision''')
                    this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_fimath_productmode'));
                    flag=false;
                end
            else
                this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_fimath_productmode'));
                flag=false;
            end
            if~isempty(sum_mode_exists)
                sum=fi_split{sum_mode_exists+1};
                if~contains(sum,'''fullprecision''')
                    this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_fimath_summode'));
                    flag=false;
                end
            else
                this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_fimath_summode'));
                flag=false;
            end

        end

        if emchart(i).SaturateOnIntegerOverflow


            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_mlfb_warning'),emchart(i).Path,1,DAStudio.message('HDLShared:hdlmodelchecker:desc_Saturate_Int_Overflow'));
            flag=false;
        end
    end
end
