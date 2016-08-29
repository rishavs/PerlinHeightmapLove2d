debug = true
local pixel_gradient_obj = {}

local zoom_factor = 10
 

function love.load(arg)
    generate()
end

function love.draw(dt)
    for id, pixel in pairs(pixel_gradient_obj) do
        love.graphics.setColor(pixel.lum, pixel.lum, pixel.lum)
        love.graphics.points(pixel.x, pixel.y)
   
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)    
end

function love.update(dt)

end

function love.keypressed(key)
    if key == "space" then
        generate()
    end
end
------------------------------------------
function generate()
    set_pixel_gradient()
end

function set_pixel_gradient()
    local min_elv = 1
    local max_elv = 0
    love.math.setRandomSeed(os.time())
    local seed =  love.math.random()
    print("Seed : " .. seed)
    
    local var_a = 0.5
    local var_b = 0.5
    local var_c = 0.01
    
    for w = 0, love.graphics.getWidth(), 2 do
        for h = 0, love.graphics.getHeight(), 2 do
            
            -- local p_grad = love.math.random( )
            -- local nx = w / love.graphics.getWidth() - 0.5 
            -- local ny = h / love.graphics.getHeight() - 0.5;
            
            local dx = 2 * w / love.graphics.getWidth() - 1
            local dy = 2 * h / love.graphics.getHeight() - 1
            -- at this point 0 <= dx <= 1 and 0 <= dy <= 1
            local d_sqr =  dx*dx + dy*dy
            
            -- Manhattan Distance
            local m_dist = 2*math.max(math.abs(dx), math.abs(dy))
            
            local merged_noise =    
                  1.00  * love.math.noise (( 1 + seed) * dx, ( 1 + seed) * dy)
                + 0.50  * love.math.noise (( 2 + seed) * dx, ( 2 + seed) * dy)
                + 0.25  * love.math.noise (( 4 + seed) * dx, ( 4 + seed) * dy)
                + 0.13  * love.math.noise (( 8 + seed) * dx, ( 8 + seed) * dy)
                + 0.06  * love.math.noise ((16 + seed) * dx, (16 + seed) * dy)
                + 0.03  * love.math.noise ((32 + seed) * dx, (32 + seed) * dy)
                + 0.02  * love.math.noise ((64 + seed) * dx, (64 + seed) * dy)

            -- local elevation = merged_noise  + var_a - (var_b * (m_dist ^ var_c))
            local elevation = (merged_noise + var_a) * (1 - (var_b*m_dist^var_c))
            
            
            if elevation < 0.4 + 0.45 * d_sqr then
                elevation = 0
            end
            
            local p_id = w .. "x" .. h .. "y"
            
            pixel_gradient_obj[p_id] = {
                x = w,
                y = h,
                elevation = elevation,
                lum = math.min(round(elevation * 255 ), 255)
            }
            
            -- just debug info to find the lowest elevation
            if elevation < min_elv then
                min_elv = elevation
            end
            -- just debug info to find the highest elevation
            if elevation > max_elv then
                max_elv = elevation
            end
            
        end
    end
    print("Min Elevation: " .. min_elv)
    print("Max Elevation: " .. max_elv)
end

function round(num, dp)
    local mult = 10^(dp or 0)
    return (math.floor(num * mult + 0.5)) / mult
end
