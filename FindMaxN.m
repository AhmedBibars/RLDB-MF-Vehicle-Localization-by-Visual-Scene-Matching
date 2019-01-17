function [MaxVector] = FindMaxN (InputVector,NumberOfElements,ExeclostionHalfLegth)     %MinVector= [Value,Location]        % function find minmium N values in a vector
MaxVector=zeros(NumberOfElements,2);
MinElement=min(InputVector)-1;

for i=1:NumberOfElements
    [MaxVector(i,1),MaxVector(i,2)]=max(InputVector);
    StartExeclostion=max(1,(MaxVector(i,2)-ExeclostionHalfLegth));
    EndExeclostion=min(size(InputVector,1),MaxVector(i,2)+ExeclostionHalfLegth);
    InputVector(StartExeclostion:EndExeclostion,1)=MinElement;%0;%MaxElement;           % replace the last discovered value with number greater than all vector elements.
end