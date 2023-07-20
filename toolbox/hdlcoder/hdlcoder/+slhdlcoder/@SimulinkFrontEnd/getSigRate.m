function sigRate=getSigRate(this,oportHandle)



    cst=get_param(oportHandle,'CompiledSampleTime');
    this.addDutRate(oportHandle);

    if~isempty(cst)
        if iscell(cst)
            if(length(cst)==2&&isequal(cst{2},[inf,0]))



                cst=cst{1};
                sigRate=cst(1);
            elseif(length(cst)==2&&isequal(cst{1},[inf,0]))



                cst=cst{2};
                sigRate=cst(1);
            else

                sigRate=0;
            end
        else
            if cst==[0,1]%#ok<BDSCA>

                cst(2)=0;
            end
            if cst==[-1,-1]%#ok<BDSCA>

                cst(2)=0;
            end
            if cst(2)~=0&&~isequal(cst,[inf,inf])

                if cst(1)~=0
                    port=get_param(oportHandle,'Parent');
                    msgobj=message('hdlcoder:engine:SampleTimeOffsetNotSupported',...
                    port,sprintf('%d',cst(2)));
                    this.updateChecks(getfullname(port),'block',msgobj,'Error');
                end
            end

            sigRate=cst(1);
        end
    else
        sigRate=0;
    end
end
