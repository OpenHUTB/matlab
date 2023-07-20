function bool=mcodeDefaultIsParameter(hObj,hProp)





    bool=false;
    if isa(hObj,'matlab.graphics.Graphics')
        name=hProp.Name;
        bool=localGenericHG_mcodeIsParameter(name);
    end

    if bool
        return;
    end

    if ishghandle(hObj,'line')
        bool=localHGLine_mcodeIsParameter(name);
    elseif ishghandle(hObj,'patch')
        bool=localHGPatch_mcodeIsParameter(name);
    elseif ishghandle(hObj,'surface')
        bool=localHGSurface_mcodeIsParameter(name);
    elseif ishghandle(hObj,'image')
        bool=localHGImage_mcodeIsParameter(name);
    end


    function bool=localGenericHG_mcodeIsParameter(name)

        param={'Parent'};
        bool=any(strcmp(name,param));



        function bool=localHGImage_mcodeIsParameter(name)

            param={'XData','YData','CData'};
            bool=any(strcmp(name,param));


            function bool=localHGSurface_mcodeIsParameter(name)

                param={'XData','YData','ZData',...
                'CDataMapping','CData',...
                'VertexNormals'};
                bool=any(strcmp(name,param));


                function bool=localHGPatch_mcodeIsParameter(name)

                    param={'XData','YData','ZData',...
                    'Vertices','Faces',...
                    'FaceVertexAlphaData','FaceVertexCData',...
                    'CDataMapping','CData',...
                    'VertexNormals'};
                    bool=any(strcmp(name,param));


                    function bool=localHGLine_mcodeIsParameter(name)

                        param={'XData','YData','ZData'};
                        bool=any(strcmp(name,param));




