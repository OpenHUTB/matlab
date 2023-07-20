classdef(Abstract)KeyHold<handle


    properties
source
ax
    end

    properties(Access=private)
keypressname
keyreleasename

keypresslistener
keyreleaselistener

keyispressed

keycell
        currentkey=[];

        started=false;
        customevd=[];
    end

    methods(Abstract,Access={?tmatlab_graphics_interaction_uiaxes_ArrowKeyPan,...
        ?matlab.graphics.interaction.uiaxes.KeyHold})
        c=start(hObj,o,e,cc)
        hold(hObj,o,e,c)
        stop(hObj,o,e,c)
    end

    methods
        function hObj=KeyHold(ax,key,source,keypressname,keyreleasename)
            hObj.ax=ax;
            hObj.keycell=key;
            hObj.keypressname=keypressname;
            hObj.keyreleasename=keyreleasename;
            hObj.source=source;
        end

        function enable(hObj)
            hObj.keypresslistener=event.listener(hObj.source,hObj.keypressname,@hObj.keypress_keyhold);
        end

        function disable(hObj)
            hObj.keypresslistener=[];
            hObj.keyreleaselistener=[];
        end
    end

    methods(Access=private)
        function keypress_keyhold(hObj,o,e)
            if hObj.started&&strcmp(e.Key,hObj.currentkey)
                hObj.hold(o,e,hObj.customevd);
            elseif hObj.started


                match=strcmp(e.Key,hObj.keycell);
                if any(match)
                    hObj.start_key(o,e);
                else
                    hObj.keyreleaselistener=[];
                end
            else
                match=strcmp(e.Key,hObj.keycell);
                if any(match)
                    hObj.start_key(o,e);
                end
            end
        end

        function keyrelease_keyhold(hObj,o,e)
            if strcmp(e.Key,hObj.currentkey)
                hObj.stop(o,e,hObj.customevd);
                hObj.customevd=[];
                hObj.currentkey=[];
                hObj.keyreleaselistener=[];
            end
        end


        function start_key(hObj,o,e)
            match=strcmp(e.Key,hObj.keycell);
            if any(match)
                hObj.currentkey=hObj.keycell{match};
                hObj.customevd=hObj.start(o,e,hObj.currentkey);
                hObj.started=true;
                hObj.keyreleaselistener=event.listener(hObj.source,hObj.keyreleasename,@(o,e)hObj.keyrelease_keyhold(o,e));
            end
        end
    end
end

