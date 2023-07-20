function out=emitHTML(obj)
    d=Advisor.Table(size(obj.TableData,1),size(obj.TableData,2));
    d.setHeading(obj.Title);
    d.setAttribute('class','panel');
    d.setEntries(obj.TableData);
    out=d.emitHTML;
end
