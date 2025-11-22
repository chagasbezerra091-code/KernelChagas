#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <stdbool.h>
#include <string.h>

#define MENU_ITEMS 5

int main() {
    const char *device = "/dev/input/event0"; // Ajuste para o seu teclado/botões
    int fd = open(device, O_RDONLY);
    if (fd < 0) {
        perror("Erro ao abrir dispositivo");
        return 1;
    }

    struct input_event ev;
    int menu_index = 0; // Posição atual do menu
    const char *menu[MENU_ITEMS] = {
        "Reboot system now",
        "Apply update",
        "Wipe data/factory reset",
        "Wipe cache",
        "Power off"
    };

    bool has_touch = false; // para futuro uso com touchscreen

    // Desenha menu inicial
    printf("=== Recovery Menu ===\n");
    for (int i = 0; i < MENU_ITEMS; i++) {
        if (i == menu_index)
            printf(" > %s\n", menu[i]);
        else
            printf("   %s\n", menu[i]);
    }

    while (1) {
        if (read(fd, &ev, sizeof(struct input_event)) < 0) {
            perror("Erro ao ler evento");
            break;
        }

        bool redraw = false;

        // Botões físicos
        if (ev.type == EV_KEY && ev.value == 1) { // pressionado
            if (ev.code == KEY_VOLUMEUP) {
                menu_index--;
                if (menu_index < 0) menu_index = MENU_ITEMS - 1;
                redraw = true;
            } else if (ev.code == KEY_VOLUMEDOWN) {
                menu_index++;
                if (menu_index >= MENU_ITEMS) menu_index = 0;
                redraw = true;
            } else if (ev.code == KEY_POWER) {
                printf("Selecionado: %s\n", menu[menu_index]);
                break; // sai do loop após seleção
            }
        }

        // Touchscreen simples (se detectado)
        if (ev.type == EV_ABS) {
            if (ev.code == ABS_MT_POSITION_X || ev.code == ABS_MT_POSITION_Y) {
                has_touch = true;
                // Aqui você poderia mapear para mover menu_index
            }
        }

        if (redraw) {
            printf("\033[H\033[J"); // limpa tela
            printf("=== Recovery Menu ===\n");
            for (int i = 0; i < MENU_ITEMS; i++) {
                if (i == menu_index)
                    printf(" > %s\n", menu[i]);
                else
                    printf("   %s\n", menu[i]);
            }
        }
    }

    close(fd);
    return 0;
}
