-- ModuleScript: IterationUI.lua
-- Versión 2.0.0
local IterationUI = {}
IterationUI.__index = IterationUI

-- Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Helpers internos
local function createInst(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props) do inst[k] = v end
    return inst
end

-- Crea la ScreenGui principal
function IterationUI:New(title)
    local self = setmetatable({}, IterationUI)
    self.Gui = createInst("ScreenGui", {
        Name = "IterationUI",
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
    })
    -- Contenedor principal
    self.Window = createInst("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(20,20,20),
        Parent = self.Gui,
    })
    createInst("UICorner", {Parent = self.Window, CornerRadius = UDim.new(0, 8)})
    -- TopBar
    local top = createInst("Frame", {
        Name = "TopBar", Size = UDim2.new(1,0,0,30),
        BackgroundColor3 = Color3.fromRGB(15,15,15),
        Parent = self.Window,
    })
    createInst("UICorner", {Parent = top, CornerRadius = UDim.new(0,8)})
    createInst("TextLabel", {
        Name = "Title", Text = title or "IterationUI",
        Size = UDim2.new(1,-60,1,0), BackgroundTransparency = 1,
        TextColor3 = Color3.new(1,1,1), TextScaled = true,
        Font = Enum.Font.GothamBold,
        Parent = top,
    })
    -- Close button
    local closeBtn = createInst("TextButton", {
        Name = "Close", Text = "X",
        Size = UDim2.new(0,30,1,0), Position = UDim2.new(1,-30,0,0),
        BackgroundTransparency = 1, TextColor3 = Color3.new(1,0,0),
        Font = Enum.Font.GothamBold, TextScaled = true,
        Parent = top,
    })
    closeBtn.MouseButton1Click:Connect(function()
        self.Gui:Destroy()
    end)
    -- Contenedor de pestañas y contenido
    self.Sidebar = createInst("Frame", {
        Name = "Sidebar", Size = UDim2.new(0,120,1,-30), Position = UDim2.new(0,0,0,30),
        BackgroundColor3 = Color3.fromRGB(25,25,25),
        Parent = self.Window,
    })
    createInst("UIListLayout", {Parent = self.Sidebar, Padding = UDim.new(0,5)})
    self.ContentHolder = createInst("Frame", {
        Name = "Content", Size = UDim2.new(1,-120,1,-30),
        Position = UDim2.new(0,120,0,30),
        BackgroundTransparency = 1,
        Parent = self.Window,
    })
    return self
end

-- Crea una nueva pestaña (tab)
function IterationUI:CreateTab(tabName, iconId)
    local btn = createInst("TextButton", {
        Name = tabName.."Btn",
        Text = tabName,
        Size = UDim2.new(1, -10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(30,30,30),
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.Gotham,
        TextScaled = true,
        Parent = self.Sidebar,
    })
    createInst("UICorner", {Parent = btn, CornerRadius = UDim.new(0,4)})

    local page = createInst("Frame", {
        Name = tabName.."Page",
        Size = UDim2.new(1,0,1,0),
        Visible = false,
        Parent = self.ContentHolder,
    })
    createInst("UIListLayout", {Parent = page, Padding = UDim.new(0,8), FillDirection = Enum.FillDirection.Vertical})

    -- Manejo de selección
    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(self.ContentHolder:GetChildren()) do
            if p:IsA("Frame") then p.Visible = false end
        end
        page.Visible = true
    end)

    -- Si es la primera pestaña, mostrarla por defecto
    if #self.Sidebar:GetChildren() == 2 then
        btn:Activate()
        page.Visible = true
    end

    return {
        Button = btn,
        Page = page,
        AddButton = function(_, text, callback)
            local b = createInst("TextButton", {
                Text = text, Size = UDim2.new(1,0,0,30),
                BackgroundColor3 = Color3.fromRGB(40,40,40),
                TextColor3 = Color3.new(1,1,1),
                Font = Enum.Font.Gotham, TextScaled = true,
                Parent = page,
            })
            createInst("UICorner", {Parent = b, CornerRadius = UDim.new(0,4)})
            b.MouseButton1Click:Connect(callback)
            return b
        end,
        AddDropdown = function(_, labelText, options, callback)
            local frame = createInst("Frame", {
                Size = UDim2.new(1,0,0,30), BackgroundColor3 = Color3.fromRGB(40,40,40),
                Parent = page,
            })
            createInst("UICorner", {Parent = frame, CornerRadius = UDim.new(0,4)})
            local lbl = createInst("TextLabel", {
                Text = labelText, Size = UDim2.new(0.6,0,1,0),
                BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1),
                Font = Enum.Font.Gotham, TextScaled = true,
                Parent = frame,
            })
            local ddBtn = createInst("TextButton", {
                Text = "▼", Size = UDim2.new(0.4,0,1,0),
                Position = UDim2.new(0.6,0,0,0),
                BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1),
                Font = Enum.Font.Gotham, TextScaled = true,
                Parent = frame,
            })
            -- Lista desplegable oculta
            local list = createInst("Frame", {
                Size = UDim2.new(1,0,0,#options*30),
                Position = UDim2.new(0,30,1,0),
                BackgroundColor3 = Color3.fromRGB(30,30,30),
                Visible = false,
                Parent = frame,
            })
            createInst("UICorner", {Parent = list, CornerRadius = UDim.new(0,4)})
            for i,opt in ipairs(options) do
                local optBtn = createInst("TextButton", {
                    Text = opt, Size = UDim2.new(1,0,0,30),
                    Position = UDim2.new(0,0,0,(i-1)*30),
                    BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1),
                    Font = Enum.Font.Gotham, TextScaled = true,
                    Parent = list,
                })
                optBtn.MouseButton1Click:Connect(function()
                    lbl.Text = opt
                    list.Visible = false
                    callback(opt)
                end)
            end
            ddBtn.MouseButton1Click:Connect(function()
                list.Visible = not list.Visible
            end)
            return {Frame = frame, Label = lbl, Button = ddBtn}
        end,
    }
end

-- Notificación simple
function IterationUI:Notify(title, message, duration)
    duration = duration or 3
    local notif = createInst("Frame", {
        Size = UDim2.new(0,250,0,80),
        Position = UDim2.new(1,-260,0.5,-40),
        BackgroundColor3 = Color3.fromRGB(25,25,25),
        Parent = self.Gui,
    })
    createInst("UICorner", {Parent = notif, CornerRadius = UDim.new(0,6)})
    createInst("TextLabel", {
        Text = title, Size = UDim2.new(1,0,0,30),
        BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold, TextScaled = true,
        Parent = notif,
    })
    createInst("TextLabel", {
        Text = message, Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,0.3,0),
        BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.Gotham, TextWrapped = true,
        Parent = notif,
    })
    -- Tween de salida
    delay(duration, function()
        local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
        TweenService:Create(notif, ti, {Position=UDim2.new(1,300,0.5,-40)}):Play()
        wait(0.5)
        notif:Destroy()
    end)
end

return IterationUI
