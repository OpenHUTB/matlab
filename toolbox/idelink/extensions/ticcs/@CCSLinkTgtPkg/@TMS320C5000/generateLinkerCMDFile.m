function linkerCmdFile=generateLinkerCMDFile(h,modelname,tgtinfo,mdlinfo)




    tgtinfo.mem.custom=convertPlacementsToCell(tgtinfo.mem.custom);
    tgtinfo.mem.compiler=convertPlacementsToCell(tgtinfo.mem.compiler);

    linkerCmdFile=[modelname,'.cmd'];
    fid=fopen(linkerCmdFile,'w');

    PrintMEMORY(fid,tgtinfo);
    PrintSECTIONS(fid,tgtinfo,mdlinfo);

    fclose(fid);


    function PrintMEMORY(fid,tgtinfo)
        fprintf(fid,'MEMORY\n');
        fprintf(fid,'{\n');
        fprintf(fid,'    MMR:\t org=0x000, len=0x0C0\n');
        for i=1:tgtinfo.mem.numBanks
            fprintf(fid,'    %s:\t org=0x%x, len=0x%x\n',...
            tgtinfo.mem.bank(i).name,...
            tgtinfo.mem.bank(i).addr,...
            tgtinfo.mem.bank(i).size);

        end
        fprintf(fid,'}\n');


        function PrintSECTIONS(fid,tgtinfo,mdlinfo)
            fprintf(fid,'SECTIONS\n');
            fprintf(fid,'{\n');
            PrintSECTIONS_Default(fid,tgtinfo,mdlinfo);
            PrintSECTIONS_Custom(fid,tgtinfo,mdlinfo)
            fprintf(fid,'}\n');


            function PrintSECTIONS_Default(fid,tgtinfo,mdlinfo)
                stackfound=0;
                for i=1:tgtinfo.mem.compiler.numSections
                    fprintf(fid,'    %s:\t > %s\n',...
                    tgtinfo.mem.compiler.section(i).name,...
                    tgtinfo.mem.compiler.section(i).placement{1});

                    if strcmp(tgtinfo.mem.compiler.section(i).name,'.stack')
                        stackfound=1;
                    end
                end



                if~stackfound
                    datamembank=createDataMemList(tgtinfo.mem);
                    fprintf(fid,'    %s:\t > %s\n','.stack',datamembank{1});
                end



                function PrintSECTIONS_Custom(fid,tgtinfo,mdlinfo)
                    for i=1:tgtinfo.mem.custom.numSections
                        fprintf(fid,'    %s:\t > %s\n',tgtinfo.mem.custom.section(i).name,...
                        tgtinfo.mem.custom.section(i).placement{1});
                    end
                    for i=1:mdlinfo.numBoundMemorySections
                        sectionName=mdlinfo.boundSectionName{i};
                        for j=1:tgtinfo.mem.custom.numSections
                            if strcmpi(sectionName,tgtinfo.mem.custom.section(j).name)
                                fclose(fid);
                                error(message('ERRORHANDLER:tgtpref:CustomMemorySectionAlreadyBound',...
                                sectionName));
                            end
                        end
                        fprintf(fid,'    %s:\tload = 0x%s\n',sectionName,...
                        dec2hex(mdlinfo.boundSectionStartAddress{i}));
                    end



                    function memList=createDataMemList(mem)
                        memList={};
                        for i=1:mem.numBanks,
                            if~strcmpi(mem.bank(i).contents,'Code')
                                memList={memList{:},mem.bank(i).name};
                            end
                        end


                        function obj=convertPlacementsToCell(obj)
                            for i=1:obj.numSections
                                val=obj.section(i).placement;
                                if ischar(val)
                                    obj.section(i).placement={val};
                                end
                            end


