











function coverageInfo=patchCoverageInfo(coverageInfo)


    for i=1:length(coverageInfo)
        coverageInfo(i).DeadCodeBlocks=[];
    end

    for ii=1:length(coverageInfo)
        try
            fid=coder.internal.safefopen(coverageInfo(ii).Path);
            if fid==-1
                continue;
            end
            code=fread(fid,'*char')';
            fclose(fid);
            code=strrep(code,char(13),'');
            pst=coder.internal.MatlabPST(code,coverageInfo(ii).Path,true);
            nativemap=make1BasedNativeMap(code);

            if length(pst.Ifs)==length(coverageInfo(ii).IfInfos)
                for jj=1:length(pst.Ifs)
                    if coverageInfo(ii).IfInfos(jj).charStartIdx==nativePos(pst.Ifs(jj).charStartIdx)-1
                        coverageInfo(ii).IfInfos(jj).charExprEndIdx=nativePos(pst.Ifs(jj).charExprEndIdx);
                        coverageInfo(ii).IfInfos(jj).charElseStartIdx=nativePos(pst.Ifs(jj).charElseStartIdx)-1;
                        coverageInfo(ii).IfInfos(jj).charEndIdx=nativePos(pst.Ifs(jj).charEndIdx);
                    end
                end
            end


            for jj=1:length(pst.DeadCodeBlocks)
                coverageInfo(ii).DeadCodeBlocks(jj).charStartIdx=nativePos(pst.DeadCodeBlocks(jj).charStartIdx);
                coverageInfo(ii).DeadCodeBlocks(jj).charEndIdx=nativePos(pst.DeadCodeBlocks(jj).charEndIdx);
            end
        catch ex %#ok<NASGU>

        end
    end


    function pos=nativePos(pos)
        if pos>=1&&pos<length(nativemap)
            pos=nativemap(pos);
        end
    end

    function nativemap=make1BasedNativeMap(code)
        nativemap=repmat(-1,size(code));
        idx=1;
        for ff=1:length(code)
            ch=code(ff);
            ch_native=unicode2native(ch);
            nativemap(ff)=idx;
            idx=idx+numel(ch_native);
        end
    end
end