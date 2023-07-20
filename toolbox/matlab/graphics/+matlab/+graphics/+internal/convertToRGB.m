function[colors,invalidColors]=convertToRGB(colors)












    invalidColors=string.empty(0,1);
    if ischar(colors)||iscellstr(colors)||isstring(colors)

        colorStrings=reshape(string(colors),[],1);


        numColors=numel(colorStrings);


        rgb=NaN(numColors,3);
        invalid=false(numColors,1);


        for n=1:numColors
            try
                rgb(n,:)=hgcastvalue('matlab.graphics.datatype.RGBColor',...
                colorStrings(n));
            catch

                invalid(n)=true;
            end
        end


        colors=rgb;


        invalidColors=strtrim(colorStrings(invalid,1));
    elseif isnumeric(colors)

        numColors=size(colors,1);


        rgb=NaN(numColors,3);


        for n=1:numColors
            try
                rgb(n,:)=hgcastvalue('matlab.graphics.datatype.RGBColor',...
                colors(n,:));
            catch ME

                invalidColors=string(ME.identifier);
                break
            end
        end


        colors=rgb;
    end

end
