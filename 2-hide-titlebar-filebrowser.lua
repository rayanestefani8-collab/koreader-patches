local TitleBar = require("ui/widget/titlebar")
local Menu = require("ui/widget/menu")
local logger = require("logger")

-- 1. Hook no TitleBar para esconder os elementos visuais sem quebrar a lógica
local _orig_TitleBar_init = TitleBar.init
TitleBar.init = function(self, ...)
    _orig_TitleBar_init(self, ...)
    
    -- Detecta se o pai é o FileManager ou FileSearcher
    local parent_name = self.parent and self.parent.name
    if parent_name == "filemanager" or parent_name == "filesearcher" then
        -- Esconde mas mantém o objeto para evitar erros de referência nula
        self.show = false
    end
end

-- 2. Hook no Menu para ajustar o layout e recuperar o espaço
local _orig_Menu_init = Menu.init
Menu.init = function(self, ...)
    _orig_Menu_init(self, ...)

    -- Só aplica o patch se for o navegador de arquivos e não um popup/menu de contexto
    if (self.name == "filemanager" or self.name == "filesearcher") and self.title_bar then
        local tb = self.title_bar
        
        -- Sobrescreve o método de tamanho para o gerenciador de janelas ignorar a barra
        tb.getSize = function()
            return { w = 0, h = 0 }
        end
        
        -- Desativa a pintura (renderização) da barra
        tb.paintTo = function() end
        
        -- Força o layout do menu a re-calcular sem a altura da TitleBar
        if self.layout then
            self:setFullIndex(self.full_index)
        end
    end
end

logger.info("Patch: TitleBar removido do FileManager e Pesquisa.")
