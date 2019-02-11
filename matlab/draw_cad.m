% 11 September 2015
% script to test and animate motion
close all

% load model and set some parameters
load('TacSAT.mat');
type = 'gif';
filename = 'animation';

% Scale model to fit appropriately
TV = 1/300*[TV(:,1) TV(:,2) TV(:,3)]*ROT2(pi/2)';
boresight = [1, 0, 0];
% set up the figure window
figure('color','w')
hold all

% radius of cone at unit length
[sph.x, sph.y, sph.z]=sphere(100);
h_sph=surf(sph.x,sph.y,sph.z);

% set some rendering options
set(h_sph,'LineStyle','none','FaceColor',0.8*[1 1 1],...
    'FaceLighting','gouraud','AmbientStrength',0.5,...
    'Facealpha',0.3,'Facecolor',[0.8 0.8 0.8]);

light('Position',[0 0 100],'Style','infinite');
material dull;
axis equal;
axis off
view(30, 30)
xlabel('x')
ylabel('y')
zlabel('z')

tcs = patch('faces', TF, 'vertices', TV);
set(tcs, 'facec', 'flat');            % Set the face color flat
set(tcs, 'FaceVertexCData', TC);       % Set the color (from file)
set(tcs, 'EdgeColor','none');         % Set the edge color

% draw a reference frame (vehicle fixed)
line([0 1],[0 0],[0 0],'color','k','linewidth',3);
line([0 0],[0 1],[0 0],'color','k','linewidth',3);
line([0 0],[0 0],[0 1],'color','k','linewidth',3);

% define an example series of rotations
tspan = 1:1:500;
rot_vec = [1, 1, 0];
for ii = 1:length(tspan)
    R_b2i(:, :, ii) = expm(hat_map(rot_vec)*2*pi/500*tspan(ii));
end

switch type
    case 'gif'
        f = getframe;
        [im,map] = rgb2ind(f.cdata,256,'nodither');
    case 'movie'
%         M(1:length(tspan))= struct('cdata',[],'colormap',[]);
    nFrames = length(tspan);
    vidObj = VideoWriter([filename '.avi']);
    vidObj.Quality = 100;
    vidObj.FrameRate = 8;
    open(vidObj);
end

hold on

for ii = 1:10:length(tspan)
    
    % rotate the mesh
    nTV = TV *R_b2i(:,:,ii)';
    
    % update the mesh
    set(tcs,'Vertices',nTV);
   
    % this is the body frame of the rigid body rotated to the inertial
    % frame
    body_x = R_b2i(:, :, ii) * [1; 0; 0];
    body_y = R_b2i(:, :, ii) * [0; 1; 0];
    body_z = R_b2i(:, :, ii) * [0; 0; 1];
    
    body_x_line = line([0 body_x(1)], [0 body_x(2)], [0 body_x(3)], 'color', 'r', 'linewidth', 3);
    body_y_line = line([0 body_y(1)], [0 body_y(2)], [0 body_y(3)], 'color', 'g', 'linewidth', 3);
    body_z_line = line([0 body_z(1)], [0 body_z(2)], [0 body_z(3)], 'color', 'b', 'linewidth', 3);

    drawnow

    % render a frame
    switch type
        case 'gif'
            
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            outfile = [filename '.gif'];
            
            % On the first loop, create the file. In subsequent loops, append.
            if ii==1
                imwrite(imind,cm,outfile,'gif','DelayTime',0,'loopcount',inf);
            else
                imwrite(imind,cm,outfile,'gif','DelayTime',0,'writemode','append');
            end
        case 'movie'
%             M(ii)=getframe(gcf,[0 0 560 420]); % leaving gcf out crops the frame in the movie.
            writeVideo(vidObj,getframe(gca));
        otherwise
            fprintf('Wrong type')
    end
    delete(body_x_line)
    delete(body_y_line)
    delete(body_z_line)
end


% Output the movie as an avi file
switch type
    case 'gif'
        
        
    case 'movie'
%         movie2avi(M,[filename '.avi']);
    close(vidObj);
    
    otherwise
        
end

fprintf('\nFINISHED ANIMATION\n\n')
fprintf('\nLOOK FOR %s in current directory\n\n', [filename, '.gif'])

