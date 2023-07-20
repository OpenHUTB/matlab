function fullFileName=uiPutFile(fileFilter,title)




    done=false;
    fullFileName='';
    while~done
        done=true;
        [filename,pathname]=uiputfile(fileFilter,...
        title);

        if~isequal(filename,0)
            [res,userWrite]=cvi.ReportUtils.checkUserWrite(pathname);
            if res==0
                str=getString(message('Slvnv:simcoverage:ioerrors:FolderDoesNotExistProvide',pathname));
                done=false;
            elseif~userWrite
                str=getString(message('Slvnv:simcoverage:ioerrors:ReadOnlyDirectory'));
                done=false;
            else
                ff=fullfile(pathname,filename);
                [res,userWrite]=cvi.ReportUtils.checkUserWrite(ff);
                if res&&~userWrite
                    str=getString(message('Slvnv:simcoverage:ioerrors:ReadOnlyFile'));
                    done=false;
                else
                    done=true;
                    fullFileName=fullfile(pathname,filename);
                end
            end
            if~done
                warndlg(str,title,'modal');
            end
        end
    end
end