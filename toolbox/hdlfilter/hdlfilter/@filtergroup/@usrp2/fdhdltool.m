function varargout=fdhdltool(filterobj,varargin)





























    [cando,~]=ishdlable(filterobj);
    if~cando
        error(message('hdlfilter:filtergroup:usrp2:fdhdltool:unsupportedarch',class(filterobj)));
    end

    if~isempty(inputname(1))

        filter=filterobj;
        hHdl=fdhdlcoderui.fdhdltooldlg(filter);
        hHdl.setfiltername([inputname(1),'_copy']);
    else
        hHdl=fdhdlcoderui.fdhdltooldlg(filterobj);

        hHdl.setfiltername(['filter','_copy']);
    end

    visState='On';
    for indx=1:2:length(varargin)
        if strcmpi(varargin(indx),'visible')
            visState=varargin{indx+1};
        end
    end

    if strcmpi(visState,'On')
        hDlg=DAStudio.Dialog(hHdl);
        if nargout>=1
            varargout{1}=hDlg;
            if nargout>=2
                varargout{2}=hHdl;
                if nargout>2
                    warning(message('hdlfilter:filtergroup:usrp2:fdhdltool:fdhdltool'));
                    for i=3:nargout
                        varargout{i}=[];
                    end
                end
            end
        else

            l=handle.listener(hHdl,'CloseDialog',@close_listener);
            set(hHdl,'HDL_Listener',l);
        end
    end


    function close_listener(hHDL,en)%#ok

        delete(hHDL);




