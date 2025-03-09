import { createSignal } from 'solid-js';
import styles from './Layout.module.scss';

export default function Layout(props: any) {
  return (
    <div class={styles.root}>
      <main>{props.children}</main>
    </div>
  );
}
