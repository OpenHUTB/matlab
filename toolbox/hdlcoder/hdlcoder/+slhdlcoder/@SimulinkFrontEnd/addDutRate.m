function addDutRate(this,blkh)



    isBuildToProtectModel=this.HDLCoder.getParameter('BuildToProtectModel');

    if~this.SimulinkConnection.Model.isSampleTimeInherited||...
        (~isBuildToProtectModel&&~this.TreatAsReferencedModel)


        stime=get_param(blkh,'CompiledSampleTime');
        if(~iscell(stime))
            stime={stime};
        end

        for stimeIndex=1:length(stime)
            thisSampleTime=stime{stimeIndex};

            if(thisSampleTime(1)==-2)
                if(strcmp(get_param(blkh,'Type'),'block'))&&(slhdlcoder.SimulinkFrontEnd.isSyntheticBlock(blkh))
                    blkPath=get_param(blkh,'Parent');
                else
                    blkPath=getfullname(blkh);
                end
                msgobj=message('hdlcoder:engine:variablesampletime',blkPath);
                this.updateChecks(blkPath,'block',msgobj,'Error');
            elseif isnan(thisSampleTime(1))
                blkPath=getfullname(blkh);
                msgobj=message('hdlcoder:engine:unspecifiedsampletime',blkPath);
                this.updateChecks(blkPath,'block',msgobj,'Error');
            else
                this.hPir.addDutSampleTime(thisSampleTime(1));
            end
        end
    end
end


