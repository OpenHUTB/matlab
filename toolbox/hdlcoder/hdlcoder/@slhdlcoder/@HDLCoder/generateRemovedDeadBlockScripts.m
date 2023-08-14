function generateRemovedDeadBlockScripts(this,gp)




    deletedComps=gp.getDeletedComps;










    deletedOrigMdlH=deletedComps{1};
    if~isempty(deletedOrigMdlH)
        dceHighlightScript=fullfile(this.hdlGetBaseCodegendir,'highlightRemovedDeadBlocks.m');
        fid=fopen(dceHighlightScript,'w+');
        if fid>0
            fprintf(fid,'cs.HiliteType = ''user1'';\n');
            fprintf(fid,'cs.ForegroundColor = ''black'';\n');
            fprintf(fid,'cs.BackgroundColor = ''red'';\n');
            fprintf(fid,'set_param(0, ''HiliteAncestorsData'', cs);\n');

            for ii=1:length(deletedOrigMdlH)
                hBlk=deletedOrigMdlH(ii);
                if~isempty(hBlk)&&hBlk>0
                    nameBlk=getfullname(hBlk);
                    nameBlk=fixBlkName(nameBlk);
                    fprintf(fid,'hilite_system(''%s'',''user1'');\n',nameBlk);
                end
            end
        end
        fclose(fid);
        runlink=hdlgetrunlink(dceHighlightScript);
        hdldisp([message('hdlcoder:hdldisp:GeneratingDCEHighlightingScript').getString,runlink],1);

        clearHighlightScript=fullfile(this.hdlGetBaseCodegendir,'clearHighlightingRemovedDeadBlocks.m');
        fid=fopen(clearHighlightScript,'w+');
        if fid>0
            deletedModelH=unique(bdroot(deletedOrigMdlH));
            for ii=1:length(deletedModelH)
                hBlk=deletedModelH(ii);
                if~isempty(hBlk)&&hBlk>0
                    nameBlk=getfullname(hBlk);
                    nameBlk=fixBlkName(nameBlk);
                    fprintf(fid,'SLStudio.Utils.RemoveHighlighting(get_param(''%s'',''Handle''));\n',nameBlk);
                end
            end
        end
        fclose(fid);
        runlink=hdlgetrunlink(clearHighlightScript);
        hdldisp([message('hdlcoder:hdldisp:ClearHighlightingScript').getString,runlink],1);
    end





    deletedSyntheticList=deletedComps{2};
    if~isempty(deletedSyntheticList)
        fid=fopen(fullfile(this.hdlGetBaseCodegendir,'deletedSyntheticComps.txt'),'w+');
        if fid>0
            for ii=1:length(deletedSyntheticList)
                fprintf(fid,'%s\n',deletedSyntheticList{ii});
            end
        end
        fclose(fid);
    end
end

function names=fixBlkName(names)
    names=hdlfixblockname(names);
    names=strrep(names,"'","''");

end


