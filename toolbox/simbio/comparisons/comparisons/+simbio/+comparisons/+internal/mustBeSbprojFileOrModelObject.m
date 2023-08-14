function mustBeSbprojFileOrModelObject(input)








    if isstring(input)||ischar(input)
        if ismissing(input)
            return
        end
        mustBeTextScalar(input);
        if exist(SimBiology.internal.getCanonicalFilename(input),"file")~=2
            error(message("SimBiology:diff:FileDoesNotExist",input));
        end
    elseif~(isa(input,"SimBiology.Model")&&isscalar(input)&&isvalid(input))
        error(message("SimBiology:diff:InvalidModelInput"));
    end

end