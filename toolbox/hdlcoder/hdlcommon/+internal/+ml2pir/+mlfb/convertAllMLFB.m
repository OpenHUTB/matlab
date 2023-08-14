function convertAllMLFB(modelName,inPlaceConversion)





    if nargin<2
        inPlaceConversion=true;
    end

    mlfbPathList=internal.ml2pir.mlfb.getAllMLFB(modelName);


    if~isempty(mlfbPathList)
        sysHandle=get_param(modelName,'Handle');
        SLM3I.SLDomain.updateDiagram(sysHandle);


        for idx=1:numel(mlfbPathList)
            mlfbBlk=mlfbPathList{idx};

            [success,messages]=internal.ml2pir.mlfb.mlfb2sl(mlfbBlk,inPlaceConversion);

            if~isempty(messages)
                fprintf('\nMessages for %s:\n',mlfbBlk);

                for i=1:numel(messages)
                    printMessage(messages(i));
                end
            end

            if success
                fprintf(1,'Success Converting ---> %s\n',mlfbBlk);
            else
                fprintf(1,'Failed with Conversion ---> %s\n',mlfbBlk);
            end
        end
    end

end


