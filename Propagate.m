function [PropapilityVector]=Propagate(PropapilityVector,PropagationMatrix,ImpactMatrix)
PM=PropagationMatrix;
PM(find(PM==0))=1;
Temp=PropapilityVector(PM).*ImpactMatrix;
PropapilityVector=sum(Temp,2);
