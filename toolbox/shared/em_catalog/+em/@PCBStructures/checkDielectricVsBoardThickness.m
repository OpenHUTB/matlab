function checkDielectricVsBoardThickness(obj,propVal,mIndx,dIndx)
    m1=find(mIndx==1);
    m1=m1(1);
    d1=find(dIndx==1);
    dielthick=cellfun(@(x)(x.Thickness),propVal(d1));
    d1(d1<m1+1)=[];
    sub=propVal(d1);
    subThickness=cellfun(@(x)(x.Thickness),sub);
    tol=sqrt(eps);
    if~(abs(sum(subThickness)-(obj.BoardThickness))<tol)&&~isempty(subThickness)


        if numel(sub)==1
            propVal{d1}.Thickness=obj.BoardThickness;
            if isequal(numel(find(dIndx==1)),1)

                warning(message('antenna:antennaerrors:UpdatedDielectricThickness'));
            else
                fdiel=propVal(dIndx==1);

                warning(message('antenna:antennaerrors:UpdatedNonCoatedDielectricThickness',...
                fdiel{2}.Name,fdiel{1}.Name));
            end
        else
            error(message('antenna:antennaerrors:PcbStackDielectricLayerThicknessMisMatch'));
        end
    elseif isempty(subThickness)&&isequal(numel(find(dIndx==1)),1)&&~(abs(sum(dielthick)-(obj.BoardThickness))<tol)



        propVal{dIndx==1}.Thickness=obj.BoardThickness;
        warning(message('antenna:antennaerrors:UpdatedDielectricThickness'));
    elseif isempty(subThickness)&&~isequal(numel(find(dIndx==1)),1)&&~(abs(sum(dielthick)-(obj.BoardThickness))<tol)



        error(message('antenna:antennaerrors:PcbStackDielectricLayerThicknessMisMatch'));
    end
end