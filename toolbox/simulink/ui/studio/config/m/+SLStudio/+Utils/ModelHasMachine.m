function value=ModelHasMachine(model)




    value=~isempty(find(model,'-isa','Stateflow.Machine'));
end
