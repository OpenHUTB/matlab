function postProcess(h,modelInfo)




    try



        perlFile=fullfile(getenv('TI_C2000_DIR'),'asap2','asap2post.pl');
        if exist(perlFile,'file')
            mapFile=[modelInfo.name,'.map'];
            if exist(mapFile,'file')
                asap2file=dir([modelInfo.name,'.a2l']);
                mapfile=dir(mapFile);


                optAsap2=get_param(modelInfo.name,'GenerateASAP2');
                if(strcmp(optAsap2,'off'))

                    if(~isempty(asap2file))
                        delete(asap2file.name);
                    end;
                else

                    if~isempty(asap2file)

                        if strcmp(mapfile.name,['..',filesep,modelInfo.name,'.map'])
                            mapfile.name=[modelInfo.name,'.map'];
                        end


                        asap2post_targets([asap2file.name],mapfile.name,perlFile);
                        fprintf(1,'### Found ASAP2 file and MAP file.   Propagated addresses from MAP file into ASAP2 file\n');
                    else

                        fprintf(1,'### Error during propagation of addresses from the MAP file into the ASAP2 file\n');
                    end;
                end;
            end
        end
    catch postProcException
        newExc=MException('TICCSEXT:util:ASAP2PostProcessError',...
        'Error during post process of ASAP2 file.');
        lf_throwPjtGenError(newExc,postProcException);
    end
