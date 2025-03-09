import { Stylesheet, Title } from '@solidjs/meta';
import Layout from '~/components/Layout';

import styles from './index.module.scss';
import { onMount } from 'solid-js';

export default function Home() {
  onMount(() => {
    let light = document.getElementById('player-light');
    if (light) {
      flicker(light, 75);
    }
  });

  return (
    <Layout>
      <div class={styles.sectionBox}>
        <div class={`${styles.section} ${styles.one}`}>
          <img class={styles.player} src="/player-lantern.png" />
          <div class={styles.lightBox}>
            <img id="player-light" class={styles.light} src="/light.webp" />
          </div>
          <svg
            width="74"
            height="98"
            viewBox="0 0 74 98"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            class={styles.arrow}
          >
            <path
              d="M42 5C42 2.23858 39.7614 -1.40019e-07 37 0C34.2386 1.40018e-07 32 2.23858 32 5L42 5ZM33.4645 96.0355C35.4171 97.9882 38.5829 97.9882 40.5355 96.0355L72.3553 64.2157C74.308 62.2631 74.308 59.0973 72.3553 57.1447C70.4027 55.192 67.2369 55.192 65.2843 57.1447L37 85.4289L8.71572 57.1447C6.7631 55.192 3.59728 55.192 1.64466 57.1447C-0.307966 59.0973 -0.307966 62.2631 1.64466 64.2157L33.4645 96.0355ZM32 5L32 92.5L42 92.5L42 5L32 5Z"
              fill="#FFFFFF20"
            />
          </svg>
        </div>
        <div class={`${styles.section} ${styles.two}`}>
          <h1>echos</h1>
          <p>a game about finding your light</p>
          <div class={styles.downloads}>
            <a href="/downloads/echos-windows.exe" download>
              windows
            </a>{' '}
            <a class={styles.disabled}>mac</a>
            <a href="/downloads/echos-linux.x86_64" download>
              linux
            </a>{' '}
            <a class={styles.disabled}>web</a>
          </div>
        </div>
      </div>
    </Layout>
  );
}

function flicker(light: HTMLElement, light_range: number) {
  light_range = Math.max(
    0,
    rand_in_range(
      Math.max(300, light_range - 10),
      Math.min(400, light_range + 10)
    )
  );
  light.style.width = light_range + 'px';
  light.style.top = -light_range / 2 + 'px';
  light.style.left = -light_range / 2 + 'px';
  setTimeout(() => {
    flicker(light, light_range);
  }, rand_in_range(50, 100));
}

function rand_in_range(a: number, b: number) {
  return Math.random() * (b - a) + a;
}
