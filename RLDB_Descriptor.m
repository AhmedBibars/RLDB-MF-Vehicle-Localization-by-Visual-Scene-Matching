% This class implements the Random Local Difference Binary (RLDB)
% descriptor.
classdef RLDB_Descriptor
   properties
      CellPairsNum=1000;         % number of cell-pairs.
      MaxCellSize=8;             % maximum image-cell size.
      MinCellSize=2;             % minimum image-cell size.
      ReducedImageSize=64;       % reduces image size,  default setting 64x64 pixels.
      IlluminationNormalize=1;   % perform patch-illumination-normalization for the images before computing the descriptor.
      RegionsMat;                % image-cells reagions.
      AreaVector;                % Areas of image-cells.
   end
   methods
       function obj=SelectRandomCellPairs_UD (obj)    % select random cells with Uniform cell-area distripution
          CoordinatesVect=randi(obj.ReducedImageSize,2*obj.CellPairsNum,2);              
          X1=CoordinatesVect(:,1);  %Vecttical start Points                             
          Y1=CoordinatesVect(:,2);  %Horizontal Start Points                            
                                                                             
          BlockLengths=randi([obj.MinCellSize-1,obj.MaxCellSize-1],2*obj.CellPairsNum,1);
          X2=X1+BlockLengths;
          Y2=Y1+BlockLengths;
          X2=min(X2,obj.ReducedImageSize);
          Y2=min(Y2,obj.ReducedImageSize);

          obj.RegionsMat=[X1,X2,Y1,Y2];
          obj.AreaVector=(X2-X1).*(Y2-Y1);
       end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function obj=SelectRandomCellPairs_NUD (obj)    % select random cells with Non-Uniform cell-area distripution 
          CoordinatesVect=randi(obj.ReducedImageSize,2*obj.CellPairsNum,2);             
          X1=CoordinatesVect(:,1);  %Vecttical start Points                             
          Y1=CoordinatesVect(:,2);  %Horizontal Start Points                            
                                                                              
          PossibleBlockLengths=obj.MaxCellSize:-1:obj.MinCellSize; 
          PossibleBlockAreas=PossibleBlockLengths.*PossibleBlockLengths;
          TotalOfPossibleAreas=sum(PossibleBlockAreas);
          Step=obj.CellPairsNum/TotalOfPossibleAreas;

          AreassWeights=fliplr(PossibleBlockAreas); %wrev() % give more weight(number) for cells with smaller area.
          EachLengthNum=round(AreassWeights.*Step); % number of generated cells from each cell-size.                                            
                                                                              
          BlockLengths=obj.MinCellSize*ones(obj.CellPairsNum,1);
          FillingPointer=1;
          for i=1:size(PossibleBlockLengths,2)-1
              BlockLengths(FillingPointer:FillingPointer+EachLengthNum(i)-1)=PossibleBlockLengths(i);
              FillingPointer=FillingPointer+EachLengthNum(i);
          end
          BlockLengths=repmat(BlockLengths,2,1);

          X2=X1+BlockLengths;
          Y2=Y1+BlockLengths;
          X2=min(X2,obj.ReducedImageSize);
          Y2=min(Y2,obj.ReducedImageSize);

          obj.RegionsMat=[X1,X2,Y1,Y2];
          obj.AreaVector=(X2-X1).*(Y2-Y1);
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function Descriptor = RLDB(obj,Image)
          Image=rgb2gray(Image);
          ReducedImage=imresize(Image,[obj.ReducedImageSize ,obj.ReducedImageSize]);
          if obj.IlluminationNormalize
              ReducedImage=obj.LocalNormalize(ReducedImage,8);
          end
          BlocksNum=size(obj.RegionsMat,1);
          AbsDiffx=abs([ReducedImage(:,2:size(ReducedImage,2))-ReducedImage(:,1:(size(ReducedImage,2)-1)),zeros(size(ReducedImage,1),1)]);
          AbsDiffy=abs([ReducedImage(1:(size(ReducedImage,1)-1),:)-ReducedImage(2:size(ReducedImage,1),:);zeros(1,size(ReducedImage,2))]);
          % [Diffx,Diffy]=imgradientxy(ReducedImage);
          % AbsDiffx=abs(Diffx);AbsDiffy=abs(Diffy);

          IntegralFrame=integralImage(ReducedImage);
          IntegralAbsDiffx=integralImage(AbsDiffx);
          IntegralAbsDiffy=integralImage(AbsDiffy);

          AvgMat=zeros(BlocksNum,1);
          AbsDiffxMat=zeros(BlocksNum,1);
          AbsDiffyMat=zeros(BlocksNum,1);

          % for i=1:BlocksNum
          %     Startcolumn=RegionsMat(i,1);
          %     Endcolumn=RegionsMat(i,2);
          %     StartRow=RegionsMat(i,3);
          %     EndRow=RegionsMat(i,4);
          %            % J(eR+1,eC+1) - J(eR+1,sC) - J(sR,eC+1) + J(sR,sC)
          %     AvgMat(i,1)= IntegralFrame(EndRow+1,Endcolumn+1) - IntegralFrame(EndRow+1,Startcolumn) - IntegralFrame(StartRow,Endcolumn+1) + IntegralFrame(StartRow,Startcolumn);
          %     AbsDiffxMat(i,1)=IntegralAbsDiffx(EndRow+1,Endcolumn+1) - IntegralAbsDiffx(EndRow+1,Startcolumn) - IntegralAbsDiffx(StartRow,Endcolumn+1) + IntegralAbsDiffx(StartRow,Startcolumn);
          %     AbsDiffyMat(i,1)=IntegralAbsDiffy(EndRow+1,Endcolumn+1) - IntegralAbsDiffy(EndRow+1,Startcolumn) - IntegralAbsDiffy(StartRow,Endcolumn+1) + IntegralAbsDiffy(StartRow,Startcolumn);
          % end


          Startcolumn=obj.RegionsMat(:,1);
          Endcolumn=obj.RegionsMat(:,2)+1;
          StartRow=obj.RegionsMat(:,3);
          EndRow=obj.RegionsMat(:,4)+1;

          BottomRightIndexes = (EndRow-1)*size(IntegralFrame,1)+Endcolumn;%sub2ind(size(IntegralFrame), Endcolumn,EndRow);
          TopRightIndexes= (EndRow-1)*size(IntegralFrame,1)+Startcolumn;%sub2ind(size(IntegralFrame),Startcolumn, EndRow);
          BottomLeftIndexes=(StartRow-1)*size(IntegralFrame,1)+Endcolumn;%sub2ind(size(IntegralFrame), Endcolumn,StartRow);
          TopLeftIndexes=(StartRow-1)*size(IntegralFrame,1)+Startcolumn;%sub2ind(size(IntegralFrame), Startcolumn,StartRow);

          AvgMat(:,1)= IntegralFrame(BottomRightIndexes) - IntegralFrame(TopRightIndexes) - IntegralFrame(BottomLeftIndexes) + IntegralFrame(TopLeftIndexes);
          AbsDiffxMat(:,1)=IntegralAbsDiffx(BottomRightIndexes) - IntegralAbsDiffx(TopRightIndexes) - IntegralAbsDiffx(BottomLeftIndexes) + IntegralAbsDiffx(TopLeftIndexes);
          AbsDiffyMat(:,1)=IntegralAbsDiffy(BottomRightIndexes) - IntegralAbsDiffy(TopRightIndexes) - IntegralAbsDiffy(BottomLeftIndexes) + IntegralAbsDiffy(TopLeftIndexes);

          AvgMat=AvgMat./obj.AreaVector;
          AbsDiffxMat=AbsDiffxMat./obj.AreaVector;
          AbsDiffyMat=AbsDiffyMat./obj.AreaVector;

          AvgOut=(AvgMat(1:BlocksNum/2,1)-AvgMat(BlocksNum/2+1:BlocksNum,1))>0;
          AbsDiffxOut=(AbsDiffxMat(1:BlocksNum/2,1)-AbsDiffxMat(BlocksNum/2+1:BlocksNum,1))>0;
          AbsDiffyOut=(AbsDiffyMat(1:BlocksNum/2,1)-AbsDiffyMat(BlocksNum/2+1:BlocksNum,1))>0;

          Descriptor=[AvgOut;AbsDiffxOut;AbsDiffyOut];         
      end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function NormalizedImage=LocalNormalize(obj,IM,FilterSize)
         % Patch illumination normalization
         Filter1=ones(FilterSize,FilterSize)/(FilterSize*FilterSize);
         num=single(IM)-imfilter(single(IM),Filter1,'replicate');
         den=sqrt(imfilter(num.^2,Filter1,'replicate'));
         den(den<1)=1; %0.0001  To avoid division on small values, because they cause noise in small-variation areas (Like Sky area)
         NormalizedImage=num./den;
      end               
   end
end